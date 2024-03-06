classdef RegionExpanderLinker < RegionAdjusterLinker
    methods
        function obj = RegionExpanderLinker(gui, region)
            regionExpander = RegionExpander(region);
            callbacks = generateCallbacks(regionExpander);
            obj@RegionAdjusterLinker(gui, callbacks);
        end
    end
end



function callbacks = generateCallbacks(expander)
callbacks = {
    @expander.expandUpLeft, @expander.expandUp, @expander.expandUpRight, ...
    @expander.expandLeft, @expander.expandOut, @expander.expandRight, ...
    @expander.expandDownLeft, @expander.expandDown, @expander.expandDownRight ...
    };
callbacks = reshape(callbacks, 3, 3)';
end
