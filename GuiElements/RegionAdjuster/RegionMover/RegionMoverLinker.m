classdef RegionMoverLinker < RegionAdjusterLinker
    methods
        function obj = RegionMoverLinker(gui, region)
            regionMover = RegionMover(region);
            callbacks = generateCallbacks(regionMover);
            obj@RegionAdjusterLinker(gui, callbacks);
        end
    end
end



function callbacks = generateCallbacks(mover)
callbacks = {
    @mover.moveUpLeft, @mover.moveUp, @mover.moveUpRight, ...
    @mover.moveLeft, @mover.deleteRegion, @mover.moveRight, ...
    @mover.moveDownLeft, @mover.moveDown, @mover.moveDownRight ...
    };
callbacks = reshape(callbacks, 3, 3);
end
