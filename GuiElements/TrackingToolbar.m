classdef TrackingToolbar < handle
    properties (Access = private)
        %#ok<*PROPLC>
        trackingGui;
        regionShapeTools;
    end

    methods
        function obj = TrackingToolbar(fig, trackingGui)
            toolbar = uitoolbar(fig);

            obj.regionShapeTools = obj.generateRegionShapeSection(toolbar, trackingGui);
            
            explorerTools = generateExplorerSection(toolbar, trackingGui);
            set(explorerTools(1), "Separator", true);

            trackTool = generateTrackTool(toolbar, trackingGui);
            set(trackTool, "Separator", true);

            websiteTools = generateWebsiteTools(toolbar);
            set(websiteTools(1), "Separator", true)

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
    "ClickedCallback", @directorySelector.exportImageIfPossible ...
    );
end
function tool = generateChooseDirectoryTool(toolbar, directorySelector)
[icon, ~, ~] = imread("img/folder-open.png");
tool = uipushtool(toolbar, ...
    "Icon", icon, ...
    "ClickedCallback", @directorySelector.chooseDirectory ...
    );
end
function tool = generateOpenDirectoryTool(toolbar, directorySelector)
[icon, ~, ~] = imread("img/desktop.png");
tool = uipushtool(toolbar, ...
    "Icon", icon, ...
    "ClickedCallback", @directorySelector.openDirectory ...
    );
end

function tool = generateTrackTool(toolbar, trackingGui)
[playIcon, ~, ~] = imread("img/play.png");
tool = uipushtool(toolbar, ...
    "Icon", playIcon, ...
    "ClickedCallback", @trackingGui.trackButtonPushed ...
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
    "ClickedCallback", @(src, ev) web(url) ...
    );
end
function tool = generateGithubTool(toolbar)
[githubIcon, ~, ~] = imread("img/github-logo.png");
url = "https://github.com/jmarcinik3/BundleTracker";
tool = uipushtool(toolbar, ...
    "Icon", githubIcon, ...
    "ClickedCallback", @(src, ev) web(url) ...
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
tool = uitoggletool(toolbar, "Icon", icon, "UserData", keyword);
end
function tool = generateEllipseTool(toolbar)
icon = imread("img/ellipse.png");
keyword = RegionDrawer.ellipseKeyword;
tool = uitoggletool(toolbar, "Icon", icon, "UserData", keyword);
end
function tool = generatePolygonTool(toolbar)
icon = imread("img/polygon.png");
keyword = RegionDrawer.polygonKeyword;
tool = uitoggletool(toolbar, "Icon", icon, "UserData", keyword);
end
function tool = generateFreehandTool(toolbar)
icon = imread("img/freehand.png");
keyword = RegionDrawer.freehandKeyword;
tool = uitoggletool(toolbar, "Icon", icon, "UserData", keyword);
end

