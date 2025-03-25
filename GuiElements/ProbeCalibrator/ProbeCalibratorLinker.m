classdef ProbeCalibratorLinker < handle
    properties (Access = private)
        gui;

        psdLog;
        freqLog;
        omegaLog;
        invalidIndices;
        parameters;
        parameterErrors;

        validationCount;
        resonanceCount;
        psdPlot;
    end

    methods
        function obj = ProbeCalibratorLinker(gui, resultsParser, varargin)
            p = inputParser;
            addOptional(p, "ValidationCount", 4);
            addOptional(p, "PeakCount", 0);
            parse(p, varargin{:});
            validationCount = p.Results.ValidationCount;
            peakCount = p.Results.PeakCount;

            resultsParser = ResultsParser(resultsParser);
            x = resultsParser.getProcessedTrace();
            fps = resultsParser.getFps();

            [psd, freq] = calculatePsd(x, fps);
            psdValid = psd;
            freqValid = freq;
            invalidIndices = peakUnmaskIndices(psd, "PeakCount", peakCount);
            psdValid(invalidIndices) = [];
            freqValid(invalidIndices) = [];

            psdLog = log10(psdValid(2:end));
            freqLog = log10(freqValid(2:end));
            omegaLog = freqLog + log10(2 * pi);

            [parameters, parameterErrors] = parameterEstimates(omegaLog, psdLog, validationCount);

            set(gui.getResonanceElement(), "ValueChangingFcn", @obj.resonanceElementChanged);
            obj.psdPlot = generatePsdPlot( ...
                gui.getAxisPsd(), ...
                freqValid, ...
                psdValid, ...
                parameters ...
                );
            AxisRoiArrow(gui.getAxisRoi(), resultsParser);

            obj.psdLog = psdLog;
            obj.freqLog = freqLog;
            obj.omegaLog = omegaLog;
            obj.invalidIndices = invalidIndices;

            obj.parameters = parameters;
            obj.parameterErrors = parameterErrors;
            obj.validationCount = validationCount;
            obj.gui = gui;

            obj.updatePsdFit(); % must come after instantiating properties
        end
    end

    %% Functions to generate GUI
    methods (Static)
        function openFigure(resultsParser)
            fig = uifigure();
            gui = ProbeCalibratorGui(fig);
            ProbeCalibratorLinker(gui, resultsParser);
        end
    end

    %% Functions to retrieve state information
    methods (Access = private)
        function [drag, dragError] = getDragCoefficient(obj)
            % units of k_BT s / L^2
            drag = obj.parameters(1);
            dragError = obj.parameterErrors(1);
        end
        function [stiffness, stiffnessError] = getStiffness(obj)
            % units of k_BT / L^2
            stiffness = obj.parameters(2);
            stiffnessError = obj.parameterErrors(2);
        end
        function cutoffFreq = getCutoffFrequency(obj)
            drag = obj.getDragCoefficient();
            stiffness = obj.getStiffness();
            cutoffFreq = cutoffFrequency(drag, stiffness);
        end

        function freq = getFrequency(obj, varargin)
            freq = obj.adjustFrequency(obj.freqLog, varargin{:});
        end
        function omega = getOmega(obj, varargin)
            omega = obj.adjustFrequency(obj.omegaLog, varargin{:});
        end
        function psd = getPsd(obj, varargin)
            psd = obj.adjustFrequency(obj.psdLog, varargin{:});
        end
        function freq = adjustFrequency(obj, freq, varargin)
            p = inputParser;
            addOptional(p, "IsValid", false);
            addOptional(p, "IsLog", false);
            parse(p, varargin{:});
            isValid = p.Results.IsValid;
            isLog = p.Results.IsLog;

            if isValid
                freq(obj.invalidIndices) = [];
            end
            if ~isLog
                freq = 10.^freq;
            end
        end
    end

    %% Functions to update state of GUI
    methods (Access = private)
        function resonanceElementChanged(obj, ~, event)
            resonanceCount = event.Value;
            psd = obj.getPsd();
            obj.invalidIndices = peakUnmaskIndices(psd, "PeakCount", resonanceCount);
            obj.updatePsdFit();
        end

        function updatePsdFit(obj)
            omegaLog = obj.getOmega( ...
                "IsLog", true, ...
                "IsValid", true ...
                );
            psdLog = obj.getPsd( ...
                "IsLog", true, ...
                "IsValid", true ...
                );

            [obj.parameters, obj.parameterErrors] = parameterEstimates( ...
                omegaLog, ...
                psdLog, ...
                obj.validationCount ...
                );

            gui = obj.gui;
            set(gui.getStiffnessLabel(), "Text", generateStiffnessLabel(obj));
            set(gui.getDragLabel(), "Text", generateDragLabel(obj));

            obj.updatePsdPlot();
        end
        function updatePsdPlot(obj)
            parameters = obj.parameters;
            psdPlot = obj.psdPlot;

            freq = obj.getFrequency();
            freqValid = obj.getFrequency("IsValid", true);
            omegaLog = obj.getOmega("IsLog", true);
            psdValid = obj.getPsd("IsValid", true);

            cutoffFreq = obj.getCutoffFrequency();
            psdFit = 10 .^ psdFittingFunction(parameters, omegaLog);
            cutoffPsd = interp1(freq, psdFit, cutoffFreq, "linear");
            referenceVolume = 10 * log10(psdFit(1));

            set(psdPlot.PsdLine, ...
                "XData", freqValid, ...
                "YData", intensityToVolume(psdValid, referenceVolume) ...
                );
            set(psdPlot.PsdFit, ...
                "XData", freq, ...
                "YData", intensityToVolume(psdFit, referenceVolume) ...
                );
            set(psdPlot.CutoffFrequencyLine, ...
                "Value", cutoffFreq, ...
                "Label", generateCutoffFrequencyLabel(cutoffFreq) ...
                );
            set(psdPlot.CutoffFrequencyPoint, ...
                "XData", cutoffFreq, ...
                "YData", intensityToVolume(cutoffPsd, referenceVolume) ...
                )
        end
    end
end



function label = generateStiffnessLabel(obj)
[stiffness, stiffnessError] = obj.getStiffness();
unitLabel = "$\mu\text{N}\cdot\text{m}^{-1}$";
stiffness = 4.114e3 * stiffness;
stiffnessError = 4.114e3 * stiffnessError;

label = sprintf( ...
    "Stiffness: $%s$ %s", ...
    formatNumber(stiffness, stiffnessError), ...
    unitLabel ...
    );
end
function label = generateDragLabel(obj)
[drag, dragError] = obj.getDragCoefficient();
unitLabel = "$\text{nN}\cdot\text{s}\cdot\text{m}^{-1}$";
drag = 4.114e6 * drag;
dragError = 4.114e6 * dragError;

label = sprintf( ...
    "Drag Coefficient: $%s$ %s", ...
    formatNumber(drag, dragError), ...
    unitLabel ...
    );
end
function label = formatNumber(x, xerr)
label = formatNumberWithUncertainty( ...
    x, ...
    xerr, ...
    "Precision", 2, ...
    "Format", 's', ...
    "UseTex", true ...
    );
end

function plotLines = generatePsdPlot(ax, freq, psd, parameters)
drag = parameters(1);
stiffness = parameters(2);
omegaLog = log10(2 * pi * freq);
psdFit = 10 .^ psdFittingFunction(parameters, omegaLog);

cutoffFreq = cutoffFrequency(drag, stiffness);
cutoffPsd = interp1(freq, psdFit, cutoffFreq, "linear");

referenceVolume = 10 * log10(psdFit(1));
psdVolume = intensityToVolume(psd, referenceVolume);
psdFitVolume = intensityToVolume(psdFit, referenceVolume);
cutoffPsdVolume = intensityToVolume(cutoffPsd, referenceVolume);

hold(ax, "on");
xlabel(ax, "Frequency [Hz]");
ylabel(ax, "Power Spectral Density [dB]");
xscale(ax, "log");

plotLines = struct();
plotLines.PsdLine = plot(ax, ...
    freq, ...
    psdVolume, ...
    "Color", [0.8, 0.8, 0.8] ...
    );
plotLines.PsdFit = plot(ax, ...
    freq, ...
    psdFitVolume, ...
    "Color", "black" ...
    );
plotLines.CutoffFrequencyLine = xline(ax, ...
    cutoffFreq, ...
    "Interpreter", "latex", ...
    "Label", generateCutoffFrequencyLabel(cutoffFreq), ...
    "LabelHorizontalAlignment", "left", ...
    "LabelVerticalAlignment", "top", ...
    "LabelOrientation", "horizontal", ...
    "Color", "black", ...
    "LineStyle", "--" ...
    );
plotLines.CutoffFrequencyPoint = scatter(ax, ...
    cutoffFreq, ...
    cutoffPsdVolume, ...
    20, ...
    "filled", ...
    "MarkerFaceColor", "black" ...
    );

hold(ax, "off");
end
function cutoffLabel = generateCutoffFrequencyLabel(cutoffFreq)
cutoffLabel = sprintf('$f_c=%d$ Hz', round(cutoffFreq));
end
function cutoffFreq = cutoffFrequency(drag, stiffness)
cutoffFreq = stiffness / (2 * pi * drag);
end
function volume = intensityToVolume(x, referenceVolume)
volume = 10 * log10(x) - referenceVolume;
end

function removeIndices = peakUnmaskIndices(psd, varargin)
p = inputParser;
addOptional(p, "PeakCount", 1);
addOptional(p, "WindowWidth", 50);
parse(p, varargin{:});
peakCount = p.Results.PeakCount;
windowWidth = p.Results.WindowWidth;

removeIndices = [];
if peakCount == 0
    return;
end

psdSmooth = movmean(psd, windowWidth);
[~, peakIndices, peakWidths, ~] = findpeaks(psdSmooth, ...
    "SortStr", "descend", ...
    "NPeaks", peakCount ...
    );

for peakNumber = 1:peakCount
    peakIndex = peakIndices(peakNumber);
    peakWidth = round(peakWidths(peakNumber));
    peakIndLower = max(peakIndex-peakWidth, 1);
    peakIndUpper = peakIndex+peakWidth;
    removeIndices = unique([removeIndices, peakIndLower:peakIndUpper]);
end
end
function [parameterMeans, parameterStds] = parameterEstimates(omegaLog, psdLog, n)
if nargin < 3
    n = 4;
end

parameters = zeros([n, 2]);
for index = 1:n
    parameter = estimateProbeParameters( ...
        omegaLog(index:n:end), ...
        psdLog(index:n:end) ...
        );
    parameters(index, :) = parameter;
end
parameterStds = std(parameters, [], 1);
parameterMeans = mean(parameters, 1);
end

function [parameters, confidenceInterval] = estimateProbeParameters(omegaLog, psdLog)
options.Display = "off";
[parameters, ~, residual, ~ , ~, ~, jacobian] = lsqcurvefit( ...
    @psdFittingFunction, ...
    [1, 1], ...
    omegaLog, ...
    psdLog, ...
    [0, 0], ...
    [Inf, Inf], ...
    options ...
    );
confidenceInterval = nlparci( ...
    parameters, ...
    residual, ...
    "Jacobian", jacobian, ...
    "Alpha", 1 - 0.683 ... % confidence interval for one standard deviation
    );
confidenceInterval = diag(confidenceInterval).';
end
function [psd, freq] = calculatePsd(x, fps)
n = round(numel(x) / 2);
[psd, freq] = pwelch(x, hann(n), 0, n, fps);
end
function psdLog = psdFittingFunction(p, omegaLog)
psdLog = psdModel(omegaLog, p(1), p(2));
end
function psdLog = psdModel(omegaLog, drag, stiffness)
% Power spectral density for cantilever beam with thermal forces (Brownian motion)
% From Bormuth et al. 2014

kT = 1; % Boltzmann temperature
betas = [1.8751041, 4.6940911, 7.8547574, 10.995541]; % solutions to -1=cos(beta)*cosh(beta)
omega = 10 .^ omegaLog;

omega1 = stiffness / drag;
lorentzianSum = 0;
for index = 1:numel(betas)
    omegaN = omega1 * (betas(index) / betas(1)).^4;
    lorentzianSum = lorentzianSum + 1 ./ (omegaN.^2 + omega.^2);
end

psdLog = log10(2 * kT ./ drag * lorentzianSum);
end
