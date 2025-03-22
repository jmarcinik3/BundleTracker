classdef AxisRoiArrow < handle
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
        function obj = AxisRoiArrow(fig, resultsParser)
            if isgraphics(fig, "axes")
                ax = fig;
            elseif isgraphics(fig, "figure")
                gl = uigridlayout(fig, [1, 1]);
                ax = uiaxes(gl);
                colormap(fig, "gray");
            end

            resultsParser = ResultsParser(resultsParser);
            firstFrame = mat2gray(resultsParser.getFirstFrame());

            hold(ax, "on");
            iIm = imshow(firstFrame, "Parent", ax);
            regionsCenter = plotRoiArrow(ax, resultsParser);
            set(iIm, "ButtonDownFcn", @obj.plotRoi);
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
            layout = tiledlayout(fig, 2, 3);
            title(layout, sprintf("Region %d", index));

            axTrace = nexttile(1);
            plotTraceX(axTrace, resultsParser, index);
            axHist = nexttile(2);
            plotHistX(axHist, resultsParser, index);
            axFft = nexttile(3);
            plotFftX(axFft, resultsParser, index);

            plotTraceY(nexttile(4), resultsParser, index);
            plotHistY(nexttile(5), resultsParser, index);
            plotFftY(nexttile(6), resultsParser, index);

            title(axTrace, "Trace");
            title(axFft, "Fourier Transform");
            title(axHist, "Distribution");

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



function regionsCenter = plotRoiArrow(ax, resultsParser, varargin)
p = inputParser;
addOptional(p, "ArrowLength", 25);
parse(p, varargin{:});
arrowLength = p.Results.ArrowLength;

angles = resultsParser.getAngleRadians();
regionCount = resultsParser.getRegionCount();
regionsCenter = zeros(regionCount, 2);

for index = 1:regionCount
    region = resultsParser.getRegion(index);
    regionCenter = getRegionCenter(region);

    angle = -angles(index);
    quiver(ax, ...
        regionCenter(1), ...
        regionCenter(2), ...
        arrowLength * cos(angle), ...
        arrowLength * sin(angle), ...
        "AutoScale", 0, ...
        "Color", "red", ...
        "LineWidth", 1, ...
        "MaxHeadSize", 1 ...
        );
    regionsCenter(index, :) = regionCenter;
end
end

function plotTraceX(ax, resultsParser, index)
plotTrace(ax, ...
    resultsParser.getTime(), ...
    resultsParser.getProcessedTrace(index), ...
    resultsParser.getProcessedTraceError(index) ...
    );
xlabel(ax, "Time [t]");
ylabel(ax, "Position [x]");
end
function plotTraceY(ax, resultsParser, index)
plotTrace(ax, ...
    resultsParser.getTime(), ...
    resultsParser.getProcessedTrace2(index), ...
    resultsParser.getProcessedTraceError2(index) ...
    );
xlabel(ax, "Time [t]");
ylabel(ax, "Position [y]");
end
function plotTrace(ax, t, x, xerr)
hold on;
errorbar(ax, ...
    t, x, xerr, ...
    "Color", AxisRoiArrow.errorColor, ...
    "CapSize", 0 ...
    );
plot(ax, t, x, "black");
hold off;
set(ax, ...
    "XLim", [t(1), t(end)], ...
    "YLim", calculateTraceLimits(x, xerr) ...
    );
end
function xlim = calculateTraceLimits(x, xerr)
if any(isnan(xerr))
    xerr = 0;
end
xmin = min(x - xerr);
xmax = max(x + xerr);
xlim = [xmin, xmax];
end

function plotHistX(ax, resultsParser, index)
plotHist(ax, ...
    resultsParser.getProcessedTrace(index), ...
    resultsParser.getProcessedTraceError(index) ...
    );
end
function plotHistY(ax, resultsParser, index)
plotHist(ax, ...
    resultsParser.getProcessedTrace2(index), ...
    resultsParser.getProcessedTraceError2(index) ...
    );
end
function plotHist(ax, x, xerr)
hold on;
histogram(ax, ...
    x, ...
    "EdgeColor", "black", ...
    "FaceColor", "black" ...
    );
hold off;

pbaspect(ax, [1, 1, 1]);
set(ax, ...
    "View", [90, -90], ...
    "XLim", calculateTraceLimits(x, xerr) ...
    );
ylabel(ax, "Count");
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

function center = getRegionCenter(region)
regionType = region.Type;
if strcmpi(regionType, "images.roi.Rectangle")
    position = region.Position;
    center = position(1:2) + 0.5 * position(3:4);
elseif strcmpi(regionType, "images.roi.Ellipse")
    center = region.Center;
elseif strcmpi(regionType, "images.roi.Polygon") ...
        || strcmpi(regionType, "images.roi.Freehand")
    position = region.Position;
    center = mean(position, 1);
end
end
function index = getClosestRegionIndex(xyClicked, regionsCenter)
dxy = regionsCenter - xyClicked;
dr = sqrt(sum(dxy.^2, 2));
[~, index] = min(dr);
end
