classdef TrackingToolbar < handle
    properties (Access = private)
        trackingLinker;
        regionShapeTools;
    end

    methods
        function obj = TrackingToolbar(fig, trackingLinker)
            toolbar = uitoolbar(fig);

            obj.regionShapeTools = obj.generateRegionShapeTools(toolbar, trackingLinker);
            explorerTools = generateExplorerTools(toolbar, trackingLinker);
            trackingTools = generateTrackingTools(toolbar, trackingLinker);
            regionOrderTools = generateRegionOrderTools(toolbar, trackingLinker);
            websiteTools = generateWebsiteTools(toolbar);

            separatedTools = [
                explorerTools(1), ...
                trackingTools(1), ...
                regionOrderTools(1), ...
                websiteTools(1) ...
                ];
            set(separatedTools, "Separator", true);

            obj.trackingLinker = trackingLinker;
        end
    end

    %% Functions to generate tools
    methods (Access = private)
        function regionShapeTools = generateRegionShapeTools(obj, toolbar, trackingLinker)
            regionShapeTools = generateRegionShapeTools(toolbar);
            blobDetectionTool = generateBlobDetectionTool(toolbar, trackingLinker);
            removeRegionsTool = generateRemoveRegionsTool(toolbar, trackingLinker);

            set(regionShapeTools, "ClickedCallback", @obj.shapeToolClicked);
            firstTool = regionShapeTools(1);
            trackingLinker.setRegionShape(firstTool.UserData);
            setToogleToolState(firstTool, true);
        end
    end

    %% Functions to handle tool callbacks
    methods (Access = private)
        function shapeToolClicked(obj, source, ~)
            shapeKeyword = source.UserData;
            trackingLinker = obj.trackingLinker;
            trackingLinker.setRegionShape(shapeKeyword);

            tools = obj.regionShapeTools;
            updateToggleToolState(source, tools);
        end
    end
end



function setToogleToolState(tools, state)
set(tools, "State", state);
end
function updateToggleToolState(activeTool, otherTools)
setToogleToolState(otherTools, false);
setToogleToolState(activeTool, true);
end

function tool = generateBlobDetectionTool(toolbar, trackingLinker)
[icon, ~, ~] = imread("img/detect-blobs.png");
tool = uipushtool(toolbar, ...
    "Icon", icon, ...
    "ClickedCallback", @trackingLinker.blobDetectionButtonPushed, ...
    "Tooltip", BlobDetectorGui.title ...
    );
end

function tool = generateRemoveRegionsTool(toolbar, trackingLinker)
[icon, ~, ~] = imread("img/remove-all.png");
tool = uipushtool(toolbar, ...
    "Icon", icon, ...
    "ClickedCallback", @trackingLinker.clearRegions, ...
    "Tooltip", "Remove All Regions (Ctrl+Shift+Alt+Del)" ...
    );
end
