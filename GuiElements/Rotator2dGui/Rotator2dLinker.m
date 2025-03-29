classdef Rotator2dLinker < handle
    properties (Access = private)
        gui;
        resultsParser;
        regionsCenter;
        arrows;
        binCount = 0;

        resultsDirectory = "";
        activeIndex = 0;
    end

    methods
        function obj = Rotator2dLinker(gui, filepath)
            [obj.resultsDirectory, ~, ~] = fileparts(filepath);

            resultsParser = ResultsParser(filepath);
            checkForPostprocessing(resultsParser);
            t = resultsParser.getTime();
            firstFrame = mat2gray(resultsParser.getFirstFrame());

            iIm = gui.getRoiImage();
            axRoi = gui.getRoiAxis();

            set(iIm, "CData", firstFrame);
            set( ...
                [gui.getLineX(), gui.getLineY()], ...
                "XData", t ...
                );
            set( ...
                [gui.getTraceAxisX(), gui.getTraceAxisY()], ...
                "XLim", [t(1), t(end)] ...
                );

            hold(axRoi, "on");
            [regionsCenter, arrows] = plotRoiArrow(axRoi, resultsParser);
            hold(axRoi, "off");
            AxisResizer(iIm, ...
                "FitToContent", true, ...
                "AddListener", false ...
                );
            AxisPanZoomer(axRoi);

            addlistener(arrows, "UData", "PostSet", @obj.arrowAngleChangedEvent);

            Rotator2dMenu(gui.getFigure(), obj);

            obj.gui = gui;
            obj.resultsParser = resultsParser;
            obj.arrows = arrows;
            obj.regionsCenter = regionsCenter;
            obj.binCount = round(sqrt(numel(t)));

            obj.arrowAngleChanged(1);
        end
    end

    %% Functions to retrieve GUI elements and state information
    methods (Access = private)
        function resultsParser = getResultsParser(obj)
            resultsParser = obj.resultsParser;
        end
        function binCount = getBinCount(obj)
            binCount = obj.binCount;
        end
        function is = isActiveIndex(obj, index)
            is = index == obj.activeIndex;
        end
        function index = getClosestRegionIndex(obj, xy)
            regionsCenter = obj.regionsCenter;
            index = getClosestRegionIndex(xy, regionsCenter);
        end

        function arrows = getArrows(obj, index)
            arrows = obj.arrows;
            if nargin == 2
                arrows = arrows(index);
            end
        end
    end

    %% Functions to update state of GUI
    methods
        function exportButtonPushed(obj, ~, ~)
            resultsParser = obj.getResultsParser();
            extensions = ResultsParser.extensions;
            title = "Export Rotated Traces";
            startDirectory = obj.resultsDirectory;
            [filepath, isfilepath] = uiputfilepath(extensions, title, startDirectory);
            if ~isfilepath
                return;
            end

            regionCount = resultsParser.getRegionCount();
            for regionIndex = 1:regionCount
                arrow = obj.getArrows(regionIndex);
                arrowAngle = getArrowAngle(arrow);
                resultsParser.rerotateTrace(arrowAngle, regionIndex);
            end
            resultsParser.export(filepath);
        end
    end
    methods (Access = private)
        function arrowAngleChangedEvent(obj, ~, event)
            arrow = event.AffectedObject;
            xyClicked = [get(arrow, "XData"), get(arrow, "YData")];
            index = obj.getClosestRegionIndex(xyClicked);
            obj.arrowAngleChanged(index);
        end
        function arrowAngleChanged(obj, index)
            arrow = obj.getArrows(index);
            arrowAngle = getArrowAngle(arrow);
            obj.arrowSelected(index);
            obj.updateTraces(index, arrowAngle);
            obj.activeIndex = index;
        end

        function arrowSelected(obj, index)
            if ~obj.isActiveIndex(index)
                arrows = obj.getArrows();
                selectedArrow = arrows(index);
                set(arrows, "Color", Rotator2dGui.inactiveColor);
                set(selectedArrow, "Color", Rotator2dGui.activeColor);
            end
        end
        function updateTraces(obj, index, arrowAngle)
            resultsParser = obj.getResultsParser();
            if nargin < 3
                arrowAngle = resultsParser.getAngleRadians(index);
            end

            lineX = obj.getLineX();
            lineY = obj.getLineY();
            heatmapC = obj.getHeatmap();
            binCount = obj.getBinCount();

            [xRotated, yRotated] = rerotateTrace(resultsParser, index, arrowAngle);
            rLim = max(sqrt(xRotated.^2 + yRotated.^2)) * [-1, 1];
            set(lineX, "YData", xRotated);
            set(lineY, "YData", yRotated);

            binEdges = linspace(rLim(1), rLim(2), binCount);
            [histCounts, xBinEdges, yBinEdges] = histcounts2(yRotated, xRotated, binEdges, binEdges);
            set( ...
                heatmapC, ...
                "CData", histCounts, ...
                "XData", xBinEdges, ...
                "YData", yBinEdges ...
                );

            if ~obj.isActiveIndex(index)
                set( ...
                    [obj.getTraceAxisX(), obj.getTraceAxisY()], ...
                    "YLim", rLim ...
                    );
                set( ...
                    obj.getHeatmapAxis(), ...
                    "XLim", rLim, ...
                    "YLim", rLim, ...
                    "YDir", "normal" ...
                    );
            end
        end
    end

    %% Helper functions to call methods from properties
    methods (Access = private)
        function gui = getGui(obj)
            gui = obj.gui;
        end
        function ax = getAxis(obj)
            ax = obj.getGui().getAxis();
        end
        function lineX = getLineX(obj)
            lineX = obj.getGui().getLineX();
        end
        function lineY = getLineY(obj)
            lineY = obj.getGui().getLineY();
        end
        function heatmap = getHeatmap(obj)
            heatmap = obj.getGui().getHeatmap();
        end
        function ax = getTraceAxisX(obj)
            ax = obj.getGui().getTraceAxisX();
        end
        function ax = getTraceAxisY(obj)
            ax = obj.getGui().getTraceAxisY();
        end
        function ax = getHeatmapAxis(obj)
            ax = obj.getGui().getHeatmapAxis();
        end
    end
end



function hasDetrend = checkForPostprocessing(resultsParser)
detrendModes = resultsParser.getDetrendMode();
hasDetrend = any(~DetrendAlgorithms.isIdentity(detrendModes));
if hasDetrend
    warning("Traces have been detrended already");
end
end
function [xRotated, yRotated] = rerotateTrace(resultsParser, index, newAngle)
x = resultsParser.getProcessedTrace(index);
y = resultsParser.getProcessedTrace2(index);
initialAngle = resultsParser.getAngleRadians(index);
[xRotated, yRotated] = TraceRotator.rotate2d(x, y, newAngle - initialAngle);
end

function [regionsCenter, arrows] = plotRoiArrow(ax, resultsParser, varargin)
p = inputParser;
addOptional(p, "ArrowLength", 25);
parse(p, varargin{:});
arrowLength = p.Results.ArrowLength;

angles = resultsParser.getAngleRadians();
regionCount = resultsParser.getRegionCount();
regionsCenter = zeros(regionCount, 2);
arrows = matlab.graphics.chart.primitive.Quiver.empty(regionCount, 0);

for index = 1:regionCount
    region = resultsParser.getRegion(index);
    regionCenter = getRegionCenter(region);

    angle = -angles(index);
    arrow = quiver( ...
        ax, ...
        regionCenter(1), ...
        regionCenter(2), ...
        arrowLength * cos(angle), ...
        arrowLength * sin(angle), ...
        "AutoScale", 0, ...
        "Color", "red", ...
        "LineWidth", 1, ...
        "MaxHeadSize", 1 ...
        );
    ArrowRotator(arrow);
    arrows(index) = arrow;
    regionsCenter(index, :) = regionCenter;
end
end
function angle = getArrowAngle(arrow)
angle = -atan2( ...
    get(arrow, "VData"), ...
    get(arrow, "UData") ...
    );
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
