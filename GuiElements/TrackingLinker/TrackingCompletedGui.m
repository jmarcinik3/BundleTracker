classdef TrackingCompletedGui < handle
    properties (Access = private, Constant)
        rows = 4;
        columns = 2;
        size = [TrackingCompletedGui.rows, TrackingCompletedGui.columns];
    end

    properties
        resultsFilepath = 0;
        imageFilepath = 0;
    end

    properties (Access = private)
        figure;
        gridLayout;
        messageElement;
        resultsSelector;
        imageSelector;
        actionButtons;
    end

    methods
        function obj = TrackingCompletedGui(fig, results, varargin)
            p = inputParser;
            addOptional(p, "ResultsFilepath", "");
            addOptional(p, "ImageFilepath", "");
            parse(p, varargin{:});
            resultsFilepath = p.Results.ResultsFilepath;
            imageFilepath = p.Results.ImageFilepath;

            gl = uigridlayout(fig, TrackingCompletedGui.size);
            actionButtons = generateActionButtons(gl);
            set(actionButtons, "ButtonPushedFcn", @obj.actionButtonPushed);

            obj.messageElement = generateMessageElement(gl, results);
            obj.resultsSelector = generateResultsSelector(gl, resultsFilepath);
            obj.imageSelector = generateImageSelector(gl, imageFilepath);
            obj.actionButtons = actionButtons;
            obj.gridLayout = gl;
            obj.figure = fig;

            layoutElements(obj);
        end
    end


    %% Functions to retrieve GUI elements
    methods (Access = private)
        function fig = getFigure(obj)
            fig = obj.figure;
        end
        function gl = getGridLayout(obj)
            gl = obj.gridLayout;
        end

        function elem = getMessageElement(obj)
            elem = obj.messageElement;
        end
        function gl = getResultsGridLayout(obj)
            gl = obj.resultsSelector.gridLayout;
        end
        function gl = getImageGridLayout(obj)
            gl = obj.imageSelector.gridLayout;
        end

        function buttons = getActionButtons(obj)
            buttons = obj.actionButtons;
        end
        function button = getApplyButton(obj)
            button = obj.actionButtons(1);
        end
        function button = getCancelButton(obj)
            button = obj.actionButtons(2);
        end
    end

    %% Functions to update state of GUI
    methods (Access = private)
        function actionButtonPushed(obj, source, ~)
            fig = obj.getFigure();
            if source == obj.getApplyButton()
                obj.resultsFilepath = obj.resultsSelector.getFilepath();
                obj.imageFilepath = obj.imageSelector.getFilepath();
            end
            close(fig);
        end
    end
end




function layoutElements(gui)
rows = TrackingCompletedGui.rows;
columns = TrackingCompletedGui.columns;

% retreive GUI elements
fig = gui.getFigure();
gl = gui.getGridLayout();
messageElement = gui.getMessageElement();
resultsGl = gui.getResultsGridLayout();
imageGl = gui.getImageGridLayout();
applyButton = gui.getApplyButton();
cancelButton = gui.getCancelButton();

% lay out full-row elements
messageElement.Layout.Row = 1;
resultsGl.Layout.Row = 2;
imageGl.Layout.Row = 3;
messageElement.Layout.Column = [1, columns];
resultsGl.Layout.Column = [1, columns];
imageGl.Layout.Column = [1, columns];

% lay out apply/cancel buttons
applyButton.Layout.Row = 4;
applyButton.Layout.Column = 1;
cancelButton.Layout.Row = 4;
cancelButton.Layout.Column = 2;

% format grid layout
set(gl, ...
    "RowSpacing", 10, ...
    "RowHeight", {40, 30, 30, 30} ...
    );
set(fig, "Position", [fig.Position(1:2), 480, 190]);
end

function selector = generateResultsSelector(gl, filepath)
extensions = {'*.mat', "MATLAB Structure"};
title = "Results Filepath";
selector = FileSelectorGui(gl, ...
    "Extensions", extensions, ...
    "Title", title, ...
    "Filepath", filepath ...
    );
end

function selector = generateImageSelector(gl, filepath)
extensions = AxisExporter.extensions;
title = "Image Filepath";
selector = FileSelectorGui(gl, ...
    "Extensions", extensions, ...
    "Title", title, ...
    "Filepath", filepath ...
    );
end


function elem = generateMessageElement(gl, results)
message = generateMessage(results);
elem = uilabel(gl, "Text", message);
end
function message = generateMessage(results)
resultsParser = ResultsParser(results);
regionCount = resultsParser.getRegionCount();
fps = resultsParser.getFps();
countMsg = sprintf("Cell Count: %d", regionCount);
fpsMsg = sprintf("FPS: %d", fps);
message = sprintf("%s, %s", countMsg, fpsMsg);
end
