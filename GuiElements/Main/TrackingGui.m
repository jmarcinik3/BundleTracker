classdef TrackingGui
    properties (Constant)
        rowHeight = 25;
    end

    properties (Access = private)
        % main window components
        gridLayout; % uigridlayout containing GUI components
        rightGridLayout % uigridlayout for rightside column

        % components to set processing and tracking methods
        imageGui;
        regionGuiPanel;
        trackingSelection;
        angleSelection;
        positiveDirection;
        scaleFactorInputElement;
        fpsInputElement;

        % components related to files
        directoryGui;
        saveFilestemElement;
    end

    methods
        function obj = TrackingGui()
            gl = generateGridLayout([2, 2]);
            rgl = generateRightGridLayout(gl);

            imageGl = ImageGui.generateGridLayout(gl);
            imageGl.Layout.Row = 2;
            imageGl.Layout.Column = 1;
            imageGui = ImageGui(imageGl);

            obj.regionGuiPanel = uipanel(rgl, ...
                "Title", "Region Editor", ...
                "TitlePosition", "centertop" ...
                );
            obj.directoryGui = DirectoryGui(gl, {1, [1, 2]});

            obj.trackingSelection = generateTrackingSelection(rgl);
            obj.angleSelection = generateAngleSelection(rgl);
            obj.positiveDirection = DirectionGui(rgl);
            obj.scaleFactorInputElement = generateScaleFactorElement(rgl);
            obj.fpsInputElement = generateFpsInputElement(rgl);
            obj.saveFilestemElement = generateSaveFilestemElement(rgl);

            obj.gridLayout = gl;
            obj.rightGridLayout = rgl;
            obj.imageGui = imageGui;

            layoutElements(obj);
            layoutImageGui(imageGui);
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
        function gui = getDirectoryGui(obj)
            gui = obj.directoryGui;
        end
        function gui = getImageGui(obj)
            gui = obj.imageGui;
        end
        function regionGuiPanel = getRegionGuiPanel(obj)
            regionGuiPanel = obj.regionGuiPanel;
        end

        % components for processing
        function elem = getTrackingSelectionElement(obj)
            elem = obj.trackingSelection;
        end
        function elem = getAngleSelectionElement(obj)
            elem = obj.angleSelection;
        end
        function elem = getPositiveDirectionElement(obj)
            elem = obj.positiveDirection.getGridLayout();
        end
        function elem = getScaleFactorInputElement(obj)
            elem = obj.scaleFactorInputElement;
        end
        function elem = getFpsInputElement(obj)
            elem = obj.fpsInputElement;
        end

        % components related to files
        function elem = getSaveFilestemElement(obj)
            elem = obj.saveFilestemElement;
        end
    end

    %% Functions to retrieve state information
    methods
        function path = getDirectoryPath(obj)
            path = obj.directoryGui.getDirectoryPath();
        end
        function val = getTrackingMode(obj)
            val = string(obj.trackingSelection.Value);
        end
        function val = getAngleMode(obj)
            val = string(obj.angleSelection.Value);
        end

        % ...for postprocessing
        function loc = getPositiveDirection(obj)
            loc = obj.positiveDirection.getLocation();
        end
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
        function fps = getFps(obj)
            gl = obj.fpsInputElement;
            textbox = gl.Children(2);
            fps = textbox.Value;
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
        function result = generateInitialResult(obj)
            result = struct( ...
                "DirectoryPath", obj.directoryGui.getDirectoryPath(), ...
                "TrackingMode", obj.getTrackingMode(), ...
                "AngleMode", obj.getAngleMode(), ...
                "Direction", obj.getPositiveDirection(), ...
                "ScaleFactor", obj.getScaleFactor(), ...
                "ScaleFactorError", obj.getScaleFactorError(), ...
                "Fps", obj.getFps() ...
                );
        end
    end
end



%% Functions to lay out elements in GUI
function layoutImageGui(imageGui)
gl = imageGui.getGridLayout();
gl.Layout.Row = 2;
gl.Layout.Column = 1;
end

function layoutElements(gui)
gl = gui.getGridLayout();
set(gl, ...
    "ColumnWidth", {'3x', '1x'}, ...
    "RowHeight", {TrackingGui.rowHeight, '1x'} ...
    );

layoutTopElements(gui);
layoutRightsideElements(gui);
end

function layoutTopElements(gui)
rowHeight = TrackingGui.rowHeight;
directoryGui = gui.getDirectoryGui();
gl = directoryGui.getGridLayout();
set(gl, "RowHeight", rowHeight);
end

function layoutRightsideElements(gui)
rowHeight = TrackingGui.rowHeight;
rgl = gui.getRightGridLayout();

positiveDirectionGroup = gui.getPositiveDirectionElement();
scaleFactorElement = gui.getScaleFactorInputElement();
fpsInputElement = gui.getFpsInputElement();
trackingDropdown = gui.getTrackingSelectionElement();
angleDropdown = gui.getAngleSelectionElement();
saveFilestemElement = gui.getSaveFilestemElement();
regionGuiPanel = gui.getRegionGuiPanel();

trackingDropdown.Layout.Row = 1;
angleDropdown.Layout.Row = 2;
positiveDirectionGroup.Layout.Row = 3;
scaleFactorElement.Layout.Row = 4;
fpsInputElement.Layout.Row = 5;
saveFilestemElement.Layout.Row = 6;
regionGuiPanel.Layout.Row = 7;

set(scaleFactorElement, ...
    "RowHeight", rowHeight, ...
    "ColumnWidth", {'3x', '3x', '1x', '2x'} ...
    );
set(fpsInputElement, ...
    "RowHeight", rowHeight, ...
    "ColumnWidth", {'1x', '2x'} ...
    );
set(saveFilestemElement, ...
    "RowHeight", rowHeight, ...
    "ColumnWidth", {'1x', '2x'} ...
    );

rgl.RowHeight = num2cell(rowHeight * ones(1, 6));
rgl.RowHeight{3} = 'fit';
rgl.RowHeight{7} = '1x';
end

function gl = generateGridLayout(size)
fig = uifigure();
position = [300, 200, 1000, 700];
set(fig, ...
    "Name", "Hair-Bundle Tracking", ...
    "Position", position ...
    );
gl = uigridlayout(fig, size);
end

function rgl = generateRightGridLayout(gl)
rgl = uigridlayout(gl, [7, 1]);
rgl.Layout.Row = 2;
rgl.Layout.Column = 2;
end

%% Function to generate tracking method dropdown
% Generates dropdown menu allowing user to select tracking method (e.g.
% "Centroid")
%
% Arguments
%
% * uigridlayout |gl|: layout to add dropdown in
%
% Returns uiddropdown
function dropdown = generateTrackingSelection(gl)
dropdown = uidropdown(gl);
dropdown.Items = TrackingAlgorithms.keywords;
end

%% Function to generate angle method dropdown
% Generates dropdown menu allowing user to select tracking method (e.g.
% "Centroid")
%
% Arguments
%
% * uigridlayout |gl|: layout to add dropdown in
%
% Returns uiddropdown
function dropdown = generateAngleSelection(gl)
dropdown = uidropdown(gl);
dropdown.Items = AngleAlgorithms.keywords;
end

%% Function to generate FPS input
% Generates edit field (with label) allowing user to set FPS
%
% Arguments
%
% * uigridlayout |parent|: layout to add edit fields in
%
% Returns uigridlayout composed of [uilabel, uieditfield("numeric")]
function gl = generateFpsInputElement(parent)
gl = uigridlayout(parent, [1 2]);
gl.Padding = [0 0 0 0];

lbl = uilabel(gl);
lbl.Text = "FPS:"; % label
tb = uieditfield(gl, "numeric");
tb.Value = 1000; % default FPS

lbl.Layout.Column = 1;
tb.Layout.Column = 2;
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
gl.Padding = [0 0 0 0];

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
