classdef TrackingToolbar < handle
    properties (Access = private)
        trackingLinker;
        regionShapeTools;
    end

    methods
        function obj = TrackingToolbar(fig, trackingLinker)
            toolbar = uitoolbar(fig);

            obj.regionShapeTools = obj.generateRegionShapeSection(toolbar, trackingLinker);
            explorerTools = generateExplorerSection(toolbar, trackingLinker);
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
        function regionShapeTools = generateRegionShapeSection(obj, toolbar, trackingLinker)
            regionShapeTools = generateRegionShapeTools(toolbar);
            blobDetectionTool = generateBlobDetectionTool(toolbar, trackingLinker);

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
[icon, ~, ~] = imread("img/detect_blobs.png");
tool = uipushtool(toolbar, ...
    "Icon", icon, ...
    "ClickedCallback", @trackingLinker.blobDetectionButtonPushed, ...
    "Tooltip", BlobDetectorGui.title ...
    );
end

function tools = generateExplorerSection(toolbar, trackingLinker)
videoSelector = trackingLinker.getVideoSelector();
saveImageTool = generateSaveImageTool(toolbar, trackingLinker);
importVideoTool = generateImportVideoTool(toolbar, videoSelector);
openDirectoryTool = generateOpenDirectoryTool(toolbar, videoSelector);
tools = [saveImageTool, importVideoTool, openDirectoryTool];
end
function tool = generateSaveImageTool(toolbar, trackingLinker)
[icon, ~, ~] = imread("img/image.png");
tool = uipushtool(toolbar, ...
    "Icon", icon, ...
    "ClickedCallback", @trackingLinker.exportImageIfPossible, ...
    "Tooltip", AxisExporter.title + " (Ctrl+S)" ...
    );
end
function tool = generateImportVideoTool(toolbar, videoSelector)
[icon, ~, ~] = imread("img/folder-open.png");
tool = uipushtool(toolbar, ...
    "Icon", icon, ...
    "ClickedCallback", @videoSelector.importVideo, ...
    "Tooltip", VideoSelector.importTitle + " (Ctrl+I)" ...
    );
end
function tool = generateOpenDirectoryTool(toolbar, videoSelector)
[icon, ~, ~] = imread("img/desktop.png");
tool = uipushtool(toolbar, ...
    "Icon", icon, ...
    "ClickedCallback", @videoSelector.openDirectory, ...
    "Tooltip", VideoSelector.openTitle + " (Ctrl+O)" ...
    );
end

function tools = generateTrackingTools(toolbar, trackingLinker)
trackTool = generateTrackTool(toolbar, trackingLinker);
tools = trackTool;
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
previousRegionTool = generatePreviousRegionTool(toolbar, trackingLinker);
nextRegionTool = generateNextRegionTool(toolbar, trackingLinker);
bringToFrontTool = generateBringRegionToFrontTool(toolbar, trackingLinker);
sendToBackTool = generateSendRegionToBackTool(toolbar, trackingLinker);
bringForwardTool = generateBringRegionForwardTool(toolbar, trackingLinker);
sendBackwardTool = generateSendRegionBackwardTool(toolbar, trackingLinker);
tools = [
    previousRegionTool, ...
    nextRegionTool, ...
    bringToFrontTool, ...
    sendToBackTool ...
    bringForwardTool, ...
    sendBackwardTool, ...
    ];
end
function tool = generatePreviousRegionTool(toolbar, trackingLinker)
[leftChevron, ~, ~] = imread("img/caret-left.png");
tool = uipushtool(toolbar, ...
    "Icon", leftChevron, ...
    "ClickedCallback", @trackingLinker.setPreviousRegionVisible, ...
    "Tooltip", "Select Previous Region (Alt+←)" ...
    );
end
function tool = generateNextRegionTool(toolbar, trackingLinker)
[rightChevron, ~, ~] = imread("img/caret-right.png");
tool = uipushtool(toolbar, ...
    "Icon", rightChevron, ...
    "ClickedCallback", @trackingLinker.setNextRegionVisible, ...
    "Tooltip", "Select Next Region (Alt+→)" ...
    );
end
function tool = generateBringRegionToFrontTool(toolbar, trackingLinker)
[icon, ~, ~] = imread("img/bring-to-front.png");
tool = uipushtool(toolbar, ...
    "Icon", icon, ...
    "ClickedCallback", @trackingLinker.bringRegionToFront, ...
    "Tooltip", "Bring Region to Front (Ctrl+Shift+Alt+↑)" ...
    );
end
function tool = generateBringRegionForwardTool(toolbar, trackingLinker)
[icon, ~, ~] = imread("img/bring-forward.png");
tool = uipushtool(toolbar, ...
    "Icon", icon, ...
    "ClickedCallback", @trackingLinker.bringRegionForward, ...
    "Tooltip", "Bring Region Forward (Alt+↑)" ...
    );
end
function tool = generateSendRegionBackwardTool(toolbar, trackingLinker)
[icon, ~, ~] = imread("img/send-backward.png");
tool = uipushtool(toolbar, ...
    "Icon", icon, ...
    "ClickedCallback", @trackingLinker.sendRegionBackward, ...
    "Tooltip", "Send Region Backward (Alt+↓)" ...
    );
end
function tool = generateSendRegionToBackTool(toolbar, trackingLinker)
[icon, ~, ~] = imread("img/send-to-back.png");
tool = uipushtool(toolbar, ...
    "Icon", icon, ...
    "ClickedCallback", @trackingLinker.sendRegionToBack, ...
    "Tooltip", "Send Region to Back (Ctrl+Shift+Alt+↓)" ...
    );
end

function tools = generateWebsiteTools(toolbar)
labWebsiteTool = generateLabWebsiteTool(toolbar);
githubTool = generateGithubTool(toolbar);
tools = [labWebsiteTool, githubTool];
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

function tools = generateRegionShapeTools(toolbar)
rectangleTool = generateRectangleTool(toolbar);
ellipseTool = generateEllipseTool(toolbar);
polygonTool = generatePolygonTool(toolbar);
freehandTool = generateFreehandTool(toolbar);
tools = [rectangleTool, ellipseTool, polygonTool, freehandTool];
end
function tool = generateRectangleTool(toolbar)
icon = imread("img/rectangle.png");
keyword = RegionDrawer.rectangleKeyword;
tool = uitoggletool(toolbar, ...
    "Icon", icon, ...
    "UserData", keyword, ...
    "Tooltip", "Draw Rectangle" ...
    );
end
function tool = generateEllipseTool(toolbar)
icon = imread("img/ellipse.png");
keyword = RegionDrawer.ellipseKeyword;
tool = uitoggletool(toolbar, ...
    "Icon", icon, ...
    "UserData", keyword, ...
    "Tooltip", "Draw Ellipse" ...
    );
end
function tool = generatePolygonTool(toolbar)
icon = imread("img/polygon.png");
keyword = RegionDrawer.polygonKeyword;
tool = uitoggletool(toolbar, ...
    "Icon", icon, ...
    "UserData", keyword, ...
    "Tooltip", "Draw Polygon" ...
    );
end
function tool = generateFreehandTool(toolbar)
icon = imread("img/freehand.png");
keyword = RegionDrawer.freehandKeyword;
tool = uitoggletool(toolbar, ...
    "Icon", icon, ...
    "UserData", keyword, ...
    "Tooltip", "Draw Freehand" ...
    );
end

