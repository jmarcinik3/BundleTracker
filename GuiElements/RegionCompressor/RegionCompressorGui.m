classdef RegionCompressorGui
    properties (Access = private, Constant)
        filepaths = "img/" + [
            ["arrow-up-left.png", "arrow-up.png", "arrow-up-right.png"]; ...
            ["arrow-left.png", "trash.png", "arrow-right.png"]; ...
            ["arrow-down-left.png", "arrow-down.png", "arrow-down-right.png"]; ...
            ];
    end

    properties (Access = private)
        gridLayout;
        imageElements;
    end

    methods
        function obj = RegionCompressorGui(parent)
            gl = generateGridLayout(parent);
            filepaths = RegionCompressorGui.filepaths;

            obj.gridLayout = gl;
            obj.imageElements = generateImageGrid(gl, filepaths);
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
