classdef TrackingToolbar < handle
    properties (Access = private)
        trackingLinker;
        regionShapeTools;
    end

    methods
        function obj = TrackingToolbar(fig, trackingLinker)
            toolbar = uitoolbar(fig);

            obj.regionShapeTools = obj.generateRegionShapeTools(toolbar, trackingLinker);
            trackingTools = generateTrackingTools(toolbar, trackingLinker);
            regionOrderTools = generateRegionOrderTools(toolbar, trackingLinker);
            websiteTools = generateWebsiteTools(toolbar);

            separatedTools = [trackingTools(1), regionOrderTools(1), websiteTools(1)];
            set(separatedTools, "Separator", true);

            obj.trackingLinker = trackingLinker;
        end
    end

    %% Functions to generate tools
    methods (Access = private)
        function regionShapeTools = generateRegionShapeTools(obj, toolbar, trackingLinker)
            regionShapeTools = generateRegionShapeTools(toolbar);
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

function tool = generateRemoveRegionsTool(toolbar, trackingLinker)
[icon, ~, ~] = imread("img/remove-all.png");
tool = uipushtool(toolbar, ...
    "Icon", icon, ...
    "ClickedCallback", @trackingLinker.clearRegions, ...
    "Tooltip", "Remove All Regions (Ctrl+Shift+Del)" ...
    );
end



function tools = generateRegionShapeTools(toolbar)
tools = [ ...
    generateRectangleTool(toolbar), ...
    generateEllipseTool(toolbar), ...
    generatePolygonTool(toolbar), ...
    generateFreehandTool(toolbar) ...
    ];
end
function tool = generateRectangleTool(toolbar)
tool = uitoggletool(toolbar, ...
    "Icon", imread("img/rectangle.png"), ...
    "UserData", RegionDrawer.rectangleKeyword, ...
    "Tooltip", "Draw Rectangle" ...
    );
end
function tool = generateEllipseTool(toolbar)
tool = uitoggletool(toolbar, ...
    "Icon", imread("img/ellipse.png"), ...
    "UserData", RegionDrawer.ellipseKeyword, ...
    "Tooltip", "Draw Ellipse" ...
    );
end
function tool = generatePolygonTool(toolbar)
tool = uitoggletool(toolbar, ...
    "Icon", imread("img/polygon.png"), ...
    "UserData", RegionDrawer.polygonKeyword, ...
    "Tooltip", "Draw Polygon" ...
    );
end
function tool = generateFreehandTool(toolbar)
tool = uitoggletool(toolbar, ...
    "Icon", imread("img/freehand.png"), ...
    "UserData", RegionDrawer.freehandKeyword, ...
    "Tooltip", "Draw Freehand" ...
    );
end

function tools = generateTrackingTools(toolbar, trackingLinker)
tools = generateTrackTool(toolbar, trackingLinker);
end
function tool = generateTrackTool(toolbar, trackingLinker)
[playIcon, ~, ~] = imread("img/play.png");
tool = uipushtool(toolbar, ...
    "Icon", playIcon, ...
    "ClickedCallback", @trackingLinker.trackButtonPushed, ...
    "Tooltip", "Start Tracking (Ctrl+↵)" ...
    );
end

function tools = generateRegionOrderTools(toolbar, trackingLinker)
tools = [
    generatePreviousRegionTool(toolbar, trackingLinker), ...
    generateNextRegionTool(toolbar, trackingLinker), ...
    generateBringRegionToFrontTool(toolbar, trackingLinker), ...
    generateSendRegionToBackTool(toolbar, trackingLinker) ...
    generateBringRegionForwardTool(toolbar, trackingLinker), ...
    generateSendRegionBackwardTool(toolbar, trackingLinker), ...
    ];
end
function tool = generatePreviousRegionTool(toolbar, trackingLinker)
[leftChevron, ~, ~] = imread("img/caret-left.png");
tool = uipushtool(toolbar, ...
    "Icon", leftChevron, ...
    "ClickedCallback", @trackingLinker.setPreviousRegionVisible, ...
    "Tooltip", "Select Previous Region (Alt+[)" ...
    );
end
function tool = generateNextRegionTool(toolbar, trackingLinker)
[rightChevron, ~, ~] = imread("img/caret-right.png");
tool = uipushtool(toolbar, ...
    "Icon", rightChevron, ...
    "ClickedCallback", @trackingLinker.setNextRegionVisible, ...
    "Tooltip", "Select Next Region (Alt+])" ...
    );
end
function tool = generateBringRegionToFrontTool(toolbar, trackingLinker)
[icon, ~, ~] = imread("img/bring-to-front.png");
tool = uipushtool(toolbar, ...
    "Icon", icon, ...
    "ClickedCallback", @trackingLinker.bringRegionToFront, ...
    "Tooltip", "Bring Region to Front (Ctrl+Shift+])" ...
    );
end
function tool = generateBringRegionForwardTool(toolbar, trackingLinker)
[icon, ~, ~] = imread("img/bring-forward.png");
tool = uipushtool(toolbar, ...
    "Icon", icon, ...
    "ClickedCallback", @trackingLinker.bringRegionForward, ...
    "Tooltip", "Bring Region Forward (Ctrl+])" ...
    );
end
function tool = generateSendRegionBackwardTool(toolbar, trackingLinker)
[icon, ~, ~] = imread("img/send-backward.png");
tool = uipushtool(toolbar, ...
    "Icon", icon, ...
    "ClickedCallback", @trackingLinker.sendRegionBackward, ...
    "Tooltip", "Send Region Backward (Ctrl+[)" ...
    );
end
function tool = generateSendRegionToBackTool(toolbar, trackingLinker)
[icon, ~, ~] = imread("img/send-to-back.png");
tool = uipushtool(toolbar, ...
    "Icon", icon, ...
    "ClickedCallback", @trackingLinker.sendRegionToBack, ...
    "Tooltip", "Send Region to Back (Ctrl+Shift+[)" ...
    );
end

function tools = generateWebsiteTools(toolbar)
tools = [ ...
    generateLabWebsiteTool(toolbar), ...
    generateGithubTool(toolbar) ...
    ];
end
function tool = generateLabWebsiteTool(toolbar)
[frogIcon, ~, ~] = imread("img/frog.png");
url = "https://bozoviclab.physics.ucla.edu";
tool = uipushtool(toolbar, ...
    "Icon", frogIcon, ...
    "ClickedCallback", @(src, ev) web(url), ...
    "Tooltip", "Open Bozovic Lab Website" ...
    );
end
function tool = generateGithubTool(toolbar)
[githubIcon, ~, ~] = imread("img/github-logo.png");
url = "https://github.com/jmarcinik3/BundleTracker";
tool = uipushtool(toolbar, ...
    "Icon", githubIcon, ...
    "ClickedCallback", @(src, ev) web(url), ...
    "Tooltip", "Open GitHub" ...
    );
end