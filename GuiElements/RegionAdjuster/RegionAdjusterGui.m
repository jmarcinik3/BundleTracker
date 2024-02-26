classdef RegionAdjusterGui
    properties (Access = private)
        gridLayout;
        imageElements;
    end

    methods
        function obj = RegionAdjusterGui(parent, filepaths, varargin)
            p = inputParser;
            addOptional(p, "Tooltips", []);
            parse(p, varargin{:});
            tooltips = p.Results.Tooltips;

            gl = generateGridLayout(parent);
            imageElements = generateImageGrid(gl, filepaths);
            if numel(tooltips) >= 0
                generateTooltips(imageElements, tooltips);
            end

            obj.gridLayout = gl;
            obj.imageElements = imageElements;
        end
    end

    %% Functions to retrieve GUI elements
    methods
        function gl = getGridLayout(obj)
            gl = obj.gridLayout;
        end
        function elems = getImageElements(obj)
            elems = obj.imageElements;
        end
    end
end


function gl = generateGridLayout(parent)
gl = uigridlayout(parent, [3, 3]);
set(gl, ...
    "Padding", [0, 0, 0, 0], ...
    "RowHeight", {16, 16, 16}, ...
    "ColumnWidth", {16, 16, 16}, ...
    "RowSpacing", 0, ...
    "ColumnSpacing", 0 ...
    );
end

function imageElements = generateImageGrid(gl, filepaths)
    function imageElement = generateImage(rowIndex, columnIndex)
        filepath = filepaths(rowIndex, columnIndex);
        imageElement = uiimage(gl, "ImageSource", filepath);
        imageElement.Layout.Row = rowIndex;
        imageElement.Layout.Column = columnIndex;
    end

imageElements = {};
[rowCount, columnCount] = size(filepaths);
for rowIndex = 1:rowCount
    for columnIndex = 1:columnCount
        imageElement = generateImage(rowIndex, columnIndex);
        imageElements{rowIndex, columnIndex} = imageElement;
    end
end
end

function generateTooltips(imageElements, tooltips)
[rowCount, columnCount] = size(imageElements);
for rowIndex = 1:rowCount
    for columnIndex = 1:columnCount
        imageElement = imageElements{rowIndex, columnIndex};
        tooltip = tooltips(rowIndex, columnIndex);
        set(imageElement, "Tooltip", tooltip);
    end
end
end
