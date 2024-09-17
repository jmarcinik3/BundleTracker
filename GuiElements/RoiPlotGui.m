classdef RoiPlotGui < handle
    properties (Constant)
        errorColor = [0.8, 0.8, 0.8];
    end

    properties (Access = private)
        resultsParser;
        regionsCenter;
        tabbedIndices = [];
        displayedIndex = 0;
    end

    methods
        function obj = RoiPlotGui(fig, resultsParser)
            resultsParser = ResultsParser(resultsParser);
            firstFrame = resultsParser.getFirstFrame();

            gl = uigridlayout(fig, [1, 1]);
            ax = uiaxes(gl);
            colormap(fig, "gray");

            hold(ax, "on");
            imshow(firstFrame, "Parent", ax);
            [regionsCenter, data] = plotRoiArrow(ax, resultsParser);
            set(data, "ButtonDownFcn", @obj.plotRoi);
            hold(ax, "off");

            obj.resultsParser = resultsParser;
            obj.regionsCenter = regionsCenter;
        end

        function displayRegionByIndex(obj, index)
            resultsParser = obj.resultsParser;

            fig = figure( ...
                "Name", sprintf("Region %d", index), ...
                "WindowStyle", "docked" ...
                );
            layout = tiledlayout(fig, 2, 2);
            title(layout, sprintf("Region %d", index));

            axTrace = nexttile;
            plotTraceX(axTrace, resultsParser, index);
            axFft = nexttile;
            plotFftX(axFft, resultsParser, index);

            plotTraceY(nexttile, resultsParser, index);
            plotFftY(nexttile, resultsParser, index);

            title(axTrace, "Trace");
            title(axFft, "Fourier Transform");

            obj.displayedIndex = index;
            obj.tabbedIndices = sort(unique([obj.tabbedIndices, index]));
        end

        function plotRoi(obj, ~, event)
            regionsCenter = obj.regionsCenter;
            xyClicked = event.IntersectionPoint(1:2);
            index = getClosestRegionIndex(xyClicked, regionsCenter);
            obj.displayRegionByIndex(index);
        end
    end
end



function plotTraceX(ax, resultsParser, index)
plotTrace(ax, ...
    resultsParser.getTime(), ...
    resultsParser.getProcessedTrace(index), ...
    resultsParser.getProcessedTraceError(index) ...
    );
xlabel(ax, "Time [t]");
ylabel(ax, "Processed Position [x]");
end
function plotTraceY(ax, resultsParser, index)
plotTrace(ax, ...
    resultsParser.getTime(), ...
    resultsParser.getProcessedTrace2(index), ...
    resultsParser.getProcessedTraceError2(index) ...
    );
xlabel(ax, "Time [t]");
ylabel(ax, "Processed Position [y]");
end
function plotTrace(ax, t, x, xerr)
hold on;
errorbar(ax, ...
    t, x, xerr, ...
    "Color", RoiPlotGui.errorColor, ...
    "CapSize", 0 ...
    );
plot(ax, t, x, "black");
hold off;
end

function plotFftX(ax, resultsParser, index)
plotFft(ax, ...
    resultsParser.getProcessedTrace(index), ...
    resultsParser.getFps() ...
    )
xlabel(ax, "Frequency [1/t]");
ylabel(ax, "Amplitude [x]");
end
function plotFftY(ax, resultsParser, index)
plotFft(ax, ...
    resultsParser.getProcessedTrace2(index), ...
    resultsParser.getFps() ...
    )
xlabel(ax, "Frequency [1/t]");
ylabel(ax, "Amplitude [y]");
end
function plotFft(ax, x, fps)
x = x.';
xCount = numel(x);
xFft = fft(x);
xFftAmplitude = abs(xFft(1:fix(xCount/2)+1)) * 2 / xCount;
xFftFrequency = (0:(xCount/2)) * fps / xCount;

plot(ax, xFftFrequency, xFftAmplitude, "black");
end

function index = getClosestRegionIndex(xyClicked, regionsCenter)
dxy = regionsCenter - xyClicked;
dr = sqrt(sum(dxy.^2, 2));
[~, index] = min(dr);
end
