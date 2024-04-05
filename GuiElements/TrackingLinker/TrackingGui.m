classdef TrackingGui
    properties (Constant)
        rowHeight = 25;
    end

    properties (Access = private)
        % main window components
        gridLayout; % uigridlayout containing GUI components
        rightGridLayout % uigridlayout for rightside column

        imagePanel;
        imageGui;
        regionPanel;
        regionGui;
        videoGui
        scaleFactorInputElement;
        saveFilestemElement;
    end

    methods
        function obj = TrackingGui()
            gl = generateGridLayout([2, 2]);
            rgl = uigridlayout(gl, [3, 1]);
            rgl.Layout.Row = 2;
            rgl.Layout.Column = 2;

            [imagePanel, imageGui] = generateImageGui(gl);
            [obj.regionPanel, obj.regionGui] = generateRegionGui(rgl);
            obj.videoGui = VideoGui(gl, {1, [1, 2]});

            obj.scaleFactorInputElement = generateScaleFactorElement(rgl);
            obj.saveFilestemElement = generateSaveFilestemElement(rgl);

            obj.gridLayout = gl;
            obj.rightGridLayout = rgl;
            obj.imagePanel = imagePanel;
            obj.imageGui = imageGui;

            layoutElements(obj);
        end
    end

    %% Functions to retrieve GUI elements
    methods
        function fig = getFigure(obj)
            gl = obj.getGridLayout();
            fig = ancestor(gl, "figure");
        end

        % compound elements
        function gl = getGridLayout(obj)
            gl = obj.gridLayout;
        end
        function rgl = getRightGridLayout(obj)
            rgl = obj.rightGridLayout;
        end
        function gui = getVideoGui(obj)
            gui = obj.videoGui;
        end
        function gui = getImageGui(obj)
            gui = obj.imageGui;
        end
        function panel = getImagePanel(obj)
            panel = obj.imagePanel;
        end
        function gui = getRegionGui(obj)
            gui = obj.regionGui;
        end
        function panel = getRegionPanel(obj)
            panel = obj.regionPanel;
        end

        % components for processing
        function elem = getScaleFactorInputElement(obj)
            elem = obj.scaleFactorInputElement;
        end

        % components related to files
        function elem = getSaveFilestemElement(obj)
            elem = obj.saveFilestemElement;
        end
    end

    %% Functions to retrieve state information
    methods
        function path = getDirectoryPath(obj)
            path = obj.videoGui.getDirectoryPath();
        end
        function filepath = getVideoFilepath(obj)
            filepath = obj.videoGui.getFilepath();
        end

        % ...for postprocessing
        function factor = getScaleFactor(obj)
            gl = obj.scaleFactorInputElement;
            textbox = gl.Children(2);
            factor = textbox.Value;
        end
        function err = getScaleFactorError(obj)
            gl = obj.scaleFactorInputElement;
            textbox = gl.Children(4);
            err = textbox.Value;
        end
        function stem = getSaveFilestem(obj)
            gl = obj.saveFilestemElement;
            textbox = gl.Children(2);
            stem = textbox.Value;
        end

        function filepath = generateSaveFilepath(obj)
            directoryPath = obj.getDirectoryPath();
            filestem = obj.getSaveFilestem();
            filename = sprintf("%s%s.mat", filestem);
            filepath = fullfile(directoryPath, filename);
        end
    end
end



%% Functions to lay out elements in GUI
function layoutElements(gui)
gl = gui.getGridLayout();
set(gl, ...
    "RowSpacing", 0, ...
    "ColumnWidth", {'3x', '1x'}, ...
    "RowHeight", {TrackingGui.rowHeight, '1x'} ...
    );

layoutTopElements(gui);
layoutRightsideElements(gui);
end

function layoutTopElements(gui)
rowHeight = TrackingGui.rowHeight;
videoGui = gui.getVideoGui();
imagePanel = gui.getImagePanel();
videoGl = videoGui.getGridLayout();

imagePanel.Layout.Row = 2;
imagePanel.Layout.Column = 1;
set(videoGl, "RowHeight", rowHeight);
end

function layoutRightsideElements(gui)
rowHeight = TrackingGui.rowHeight;
rgl = gui.getRightGridLayout();

scaleFactorElement = gui.getScaleFactorInputElement();
saveFilestemElement = gui.getSaveFilestemElement();
regionGuiPanel = gui.getRegionPanel();

scaleFactorElement.Layout.Row = 1;
saveFilestemElement.Layout.Row = 2;
regionGuiPanel.Layout.Row = 3;

set(scaleFactorElement, ...
    "Padding", [0, 0, 0, 0], ...
    "RowHeight", rowHeight, ...
    "ColumnWidth", {72, '3x', '1x', '3x'} ...
    );
set(saveFilestemElement, ...
    "Padding", [0, 0, 0, 0], ...
    "RowHeight", rowHeight, ...
    "ColumnWidth", {72, '1x'} ...
    );

set(rgl, ...
    "Padding", [0, 0, 0, 0], ...
    "RowSpacing", 0, ...
    "RowHeight", {rowHeight, rowHeight, '1x'} ...
    );
end

function gl = generateGridLayout(size)
fig = generateFigure();
position = [300, 200, 1000, 700];
set(fig, ...
    "Name", "Hair-Bundle Tracking", ...
    "Position", position ...
    );
gl = uigridlayout(fig, size);
end

function [panel, imageGui] = generateImageGui(parent)
panel = uipanel(parent, ...
    "Title", "Global Editor", ...
    "TitlePosition", "centertop" ...
    );
gl = ImageGui.generateGridLayout(panel);
imageGui = ImageGui(gl);
end

function [panel, regionGui] = generateRegionGui(parent)
panel = uipanel(parent, ...
    "Title", "Region Editor", ...
    "TitlePosition", "centertop" ...
    );
gl = RegionGui.generateGridLayout(panel);
regionGui = RegionGui(gl);
end

%% Function to generate scale factor input
% Generates edit fields (with labels) allowing user to set scaling
%
% Arguments
%
% * uigridlayout |parent|: layout to add edit fields in
%
% Returns uigridlayout composed of [uilabel, uieditfield("numeric"),
% uilabel, uieditfield("numeric")]
function gl = generateScaleFactorElement(parent)
gl = uigridlayout(parent, [1 4]);

lbl1 = uilabel(gl);
lbl1.Text = "length/px:"; % label for scaling
tb1 = uieditfield(gl, "numeric");
tb1.Value = 108.3; % default scaling

lbl2 = uilabel(gl);
lbl2.Text = "±"; % label for error
tb2 = uieditfield(gl, "numeric");
tb2.Value = 0.8; % default error

lbl1.Layout.Column = 1;
tb1.Layout.Column = 2;
lbl2.Layout.Column = 3;
tb2.Layout.Column = 4;
end

%% Function to generate save filestem input
% Generates edit field (with label) allowing user to set FPS
%
% Arguments
%
% * uigridlayout |parent|: layout to add edit field in
%
% Returns uigridlayout composed of [uilabel, uieditfield("text")]
function gl = generateSaveFilestemElement(parent)
gl = uigridlayout(parent, [1 2]);
gl.Padding = [0 0 0 0];

lbl = uilabel(gl);
lbl.Text = "Filestem:"; % label
tb = uieditfield(gl, "text");
tb.Value = "results"; % default value

lbl.Layout.Column = 1;
tb.Layout.Column = 2;
end
