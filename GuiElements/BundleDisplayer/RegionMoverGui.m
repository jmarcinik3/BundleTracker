classdef RegionMoverGui
    properties (Access = private, Constant)
        filepaths = "img/" + [
            ["arrow-up-left.png", "arrow-up.png", "arrow-up-right.png"]; ...
            ["arrow-left.png", "trash.png", "arrow-right.png"]; ...
            ["arrow-down-left.png", "arrow-down.png", "arrow-down-right.png"]; ...
            ];
    end

    properties (Access = private)
        %#ok<*PROPLC>
        gridLayout;
        imageElements;
    end

    methods
        function obj = RegionMoverGui(parent, region)
            gl = generateGridLayout(parent);
            filepaths = RegionMoverGui.filepaths;

            obj.gridLayout = gl;
            obj.imageElements = generateImageGrid(gl, filepaths);
            obj.generateImageClickedFcns(region);
        end
    end

    methods
        function gl = getGridLayout(obj)
            gl = obj.gridLayout;
        end
    end

    methods (Access = private)
        function generateImageClickedFcns(obj, region)
            imageElements = obj.imageElements;
            regionMover = RegionMover(region);
            
            imageElements{1, 1}.ImageClickedFcn = @regionMover.moveUpLeft;
            imageElements{1, 2}.ImageClickedFcn = @regionMover.moveUp;
            imageElements{1, 3}.ImageClickedFcn = @regionMover.moveUpRight;

            imageElements{2, 1}.ImageClickedFcn = @regionMover.moveLeft;
            imageElements{2, 2}.ImageClickedFcn = @regionMover.deleteRegion;
            imageElements{2, 3}.ImageClickedFcn = @regionMover.moveRight;

            imageElements{3, 1}.ImageClickedFcn = @regionMover.moveDownLeft;
            imageElements{3, 2}.ImageClickedFcn = @regionMover.moveDown;
            imageElements{3, 3}.ImageClickedFcn = @regionMover.moveDownRight;
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
imageElements = {};
[rowCount, columnCount] = size(filepaths);

for rowIndex = 1:rowCount
    for columnIndex = 1:columnCount
        filepath = filepaths(rowIndex, columnIndex);
        imageElement = uiimage(gl, "ImageSource", filepath);
        imageElement.Layout.Row = rowIndex;
        imageElement.Layout.Column = columnIndex;
        imageElements{rowIndex, columnIndex} = imageElement;
    end
end
end
