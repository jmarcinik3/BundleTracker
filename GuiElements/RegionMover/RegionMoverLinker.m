classdef RegionMoverLinker
    methods
        function obj = RegionMoverLinker(gui, region)
            regionMover = RegionMover(region);
            RegionMoverLinker.generateImageClickedFcns(gui, regionMover);
        end
    end

    methods (Access = private, Static)
        function generateImageClickedFcns(gui, regionMover)
            imageElements = gui.getImageElements();
            generateImageClickedFcns(imageElements, regionMover)
        end
    end
end



function generateImageClickedFcns(imageElements, regionMover)
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
