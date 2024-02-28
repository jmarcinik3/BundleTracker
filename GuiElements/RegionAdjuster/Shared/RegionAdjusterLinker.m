classdef RegionAdjusterLinker
    methods
        function obj = RegionAdjusterLinker(gui, callbacks)
            imageElements = gui.getImageElements();
            generateImageClickedFcns(imageElements, callbacks)
        end
    end
end



function generateImageClickedFcns(imageElements, callbacks)
[rowCount, columnCount] = size(imageElements);
for rowIndex = 1:rowCount
    for columnIndex = 1:columnCount
        callback = callbacks{rowIndex, columnIndex};
        imageElement = imageElements{rowIndex, columnIndex};
        imageElement.ImageClickedFcn = callback;
    end
end
end
