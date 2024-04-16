classdef FileSelectorGui < handle
    properties
        gridLayout;
        label;
        editfield;
        button;
    end

    properties (Access = private)
        extensions;
        title;
    end

    methods
        function obj = FileSelectorGui(parent, varargin)
            p = inputParser;
            addOptional(p, "Extensions", {});
            addOptional(p, "Title", "");
            addOptional(p, "Filepath", "");
            parse(p, varargin{:});
            extensions = p.Results.Extensions;
            title = p.Results.Title;
            filepath = p.Results.Filepath;

            gl = uigridlayout(parent, [1, 3]);
            obj.label = uilabel(gl, ...
                "Text", sprintf("%s:", title) ...
                );
            obj.editfield = uieditfield(gl, ...
                "Value", filepath, ...
                "Enable", false ...
                );
            obj.button = uibutton(gl, ...
                "Text", "Select", ...
                "ButtonPushedFcn", @obj.buttonPushed ...
                );

            obj.gridLayout = gl;
            obj.extensions = extensions;
            obj.title = title;
            layoutElements(obj);
        end
    end

    methods
        function filepath = getFilepath(obj)
            filepath = get(obj.editfield, "Value");
        end
    end

    methods (Access = private)
        function buttonPushed(obj, ~, ~)
            [filepath, isfilepath] = getFilepath(obj);
            if isfilepath
                set(obj.editfield, "Value", filepath);
            end
        end

        function dirpath = getStartingDirectory(obj)
            value = get(obj.editfield, "Value");
            [dirpath, ~, ~] = fileparts(value);
        end
    end
end



function layoutElements(gui)
gl = gui.gridLayout;
label = gui.label;
editfield = gui.editfield;
button = gui.button;

elems = [label, editfield, button];
for index = 1:numel(elems)
    elem = elems(index);
    elem.Layout.Row = 1;
    elem.Layout.Column = index;
end

set(gl, ...
    "ColumnWidth", {96, '1x', 48}, ...
    "Padding", [0, 0, 0, 0] ...
    );
end

function [filepath, isfilepath] = getFilepath(obj)
extensions = obj.extensions;
title = obj.title;
startingDirectory = obj.getStartingDirectory();
[filepath, isfilepath] = uiputfilepath(extensions, title, startingDirectory);
end
