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
    end

    methods
        function obj = TrackingGui()
            gl = generateGridLayout([2, 2]);
            rgl = uigridlayout(gl, [2, 1]);
            rgl.Layout.Row = 2;
            rgl.Layout.Column = 2;

            [imagePanel, imageGui] = generateImageGui(gl);
            [obj.regionPanel, obj.regionGui] = generateRegionGui(rgl);
            obj.videoGui = VideoGui(gl, {1, [1, 2]});

            obj.scaleFactorInputElement = generateScaleFactorElement(rgl);

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
regionGuiPanel = gui.getRegionPanel();

scaleFactorElement.Layout.Row = 1;
regionGuiPanel.Layout.Row = 2;

set(scaleFactorElement, ...
    "Padding", [0, 0, 0, 0], ...
    "RowHeight", rowHeight, ...
    "ColumnWidth", {72, '3x', '1x', '3x'} ...
    );

set(rgl, ...
    "Padding", [0, 0, 0, 0], ...
    "RowSpacing", 0, ...
    "RowHeight", {rowHeight, '1x'} ...
    );
end

function gl = generateGridLayout(size)
figDefaults = namedargs2cell(SettingsParser.getTrackingFigureDefaults());
fig = generateFigure(figDefaults{:});
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

lbl1 = uilabel(gl, "Text", "length/px:");
scaleFactorDefaults = SettingsParser.getScaleFactorDefaults();
tb1 = uieditfield(gl, "numeric", scaleFactorDefaults{:});

scaleFactorErrorDefaults = SettingsParser.getScaleFactorErrorDefaults();
lbl2 = uilabel(gl, "Text", "±");
tb2 = uieditfield(gl, "numeric", scaleFactorErrorDefaults{:});

lbl1.Layout.Column = 1;
tb1.Layout.Column = 2;
lbl2.Layout.Column = 3;
tb2.Layout.Column = 4;
end
