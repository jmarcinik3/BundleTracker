classdef TrackingToolbar < handle
    properties (Access = private)
        trackingGui;
        regionShapeTools;
    end

    methods
        function obj = TrackingToolbar(fig, trackingGui)
            toolbar = uitoolbar(fig);

            obj.regionShapeTools = obj.generateRegionShapeSection(toolbar, trackingGui);
            explorerTools = generateExplorerSection(toolbar, trackingGui);
            trackingTools = generateTrackingTools(toolbar, trackingGui);
            websiteTools = generateWebsiteTools(toolbar);

            separatedTools = [explorerTools(1), trackingTools(1), websiteTools(1)];
            set(separatedTools, "Separator", true);

            obj.trackingGui = trackingGui;
        end
    end

    %% Functions to generate tools
    methods (Access = private)
        function tools = generateRegionShapeSection(obj, toolbar, trackingGui)
            tools = generateRegionShapeTools(toolbar);
            set(tools, "ClickedCallback", @obj.shapeToolClicked);
            
            firstTool = tools(1);
            trackingGui.setRegionShape(firstTool.UserData);
            setToogleToolState(firstTool, true);
        end
    end

    %% Functions to handle tool callbacks
    methods (Access = private)
        function shapeToolClicked(obj, source, ~)
            shapeKeyword = source.UserData;
            trackingGui = obj.trackingGui;
            trackingGui.setRegionShape(shapeKeyword);

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

function tools = generateExplorerSection(toolbar, directorySelector)
saveImageTool = generateSaveImageTool(toolbar, directorySelector);
chooseDirectoryTool = generateChooseDirectoryTool(toolbar, directorySelector);
openDirectoryTool = generateOpenDirectoryTool(toolbar, directorySelector);
tools = [saveImageTool, chooseDirectoryTool, openDirectoryTool];
end
function tool = generateSaveImageTool(toolbar, directorySelector)
[icon, ~, ~] = imread("img/image.png");
tool = uipushtool(toolbar, ...
    "Icon", icon, ...
    "ClickedCallback", @directorySelector.exportImageIfPossible, ...
    "Tooltip", ImageExporter.title ...
    );
end
function tool = generateChooseDirectoryTool(toolbar, directorySelector)
[icon, ~, ~] = imread("img/folder-open.png");
tool = uipushtool(toolbar, ...
    "Icon", icon, ...
    "ClickedCallback", @directorySelector.chooseDirectory, ...
    "Tooltip", DirectorySelector.chooseTitle ...
    );
end
function tool = generateOpenDirectoryTool(toolbar, directorySelector)
[icon, ~, ~] = imread("img/desktop.png");
tool = uipushtool(toolbar, ...
    "Icon", icon, ...
    "ClickedCallback", @directorySelector.openDirectory, ...
    "Tooltip", DirectorySelector.openTitle ...
    );
end

function tools = generateTrackingTools(toolbar, trackingGui)
trackTool = generateTrackTool(toolbar, trackingGui);
previousRegionTool = generatePreviousRegionTool(toolbar, trackingGui);
nextRegionTool = generateNextRegionTool(toolbar, trackingGui);
tools = [trackTool, previousRegionTool, nextRegionTool];
end
function tool = generateTrackTool(toolbar, trackingGui)
[playIcon, ~, ~] = imread("img/play.png");
tool = uipushtool(toolbar, ...
    "Icon", playIcon, ...
    "ClickedCallback", @trackingGui.trackButtonPushed, ...
    "Tooltip", "Start Tracking" ...
    );
end
function tool = generatePreviousRegionTool(toolbar, trackingGui)
[leftChevron, ~, ~] = imread("img/caret-left.png");
tool = uipushtool(toolbar, ...
    "Icon", leftChevron, ...
    "ClickedCallback", @trackingGui.setPreviousRegionVisible, ...
    "Tooltip", "Select Previous Region (Alt+←)" ...
    );
end
function tool = generateNextRegionTool(toolbar, trackingGui)
[rightChevron, ~, ~] = imread("img/caret-right.png");
tool = uipushtool(toolbar, ...
    "Icon", rightChevron, ...
    "ClickedCallback", @trackingGui.setNextRegionVisible, ...
    "Tooltip", "Select Next Region (Alt+→)" ...
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

