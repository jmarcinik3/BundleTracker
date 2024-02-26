classdef RegionExpanderLinker
    methods
        function obj = RegionExpanderLinker(gui, region)
            regionExpander = RegionExpander(region);
            RegionExpanderLinker.generateImageClickedFcns(gui, regionExpander);
        end
    end

    methods (Access = private, Static)
        function generateImageClickedFcns(gui, regionExpander)
            imageElements = gui.getImageElements();
            generateImageClickedFcns(imageElements, regionExpander)
        end
    end
end



function generateImageClickedFcns(imageElements, regionExpander)
imageElements{1, 1}.ImageClickedFcn = @regionExpander.expandUpLeft;
imageElements{1, 2}.ImageClickedFcn = @regionExpander.expandUp;
imageElements{1, 3}.ImageClickedFcn = @regionExpander.expandUpRight;

imageElements{2, 1}.ImageClickedFcn = @regionExpander.expandLeft;
imageElements{2, 2}.ImageClickedFcn = @regionExpander.expandOut;
imageElements{2, 3}.ImageClickedFcn = @regionExpander.expandRight;

imageElements{3, 1}.ImageClickedFcn = @regionExpander.expandDownLeft;
imageElements{3, 2}.ImageClickedFcn = @regionExpander.expandDown;
imageElements{3, 3}.ImageClickedFcn = @regionExpander.expandDownRight;
end
