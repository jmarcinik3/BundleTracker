classdef RegionCompressorLinker
    methods
        function obj = RegionCompressorLinker(gui, region)
            regionCompressor = RegionCompressor(region);
            RegionCompressorLinker.generateImageClickedFcns(gui, regionCompressor);
        end
    end

    methods (Access = private, Static)
        function generateImageClickedFcns(gui, regionCompressor)
            imageElements = gui.getImageElements();
            generateImageClickedFcns(imageElements, regionCompressor)
        end
    end
end



function generateImageClickedFcns(imageElements, regionCompressor)
imageElements{1, 1}.ImageClickedFcn = @regionCompressor.compressDownRight;
imageElements{1, 2}.ImageClickedFcn = @regionCompressor.compressDown;
imageElements{1, 3}.ImageClickedFcn = @regionCompressor.compressDownLeft;

imageElements{2, 1}.ImageClickedFcn = @regionCompressor.compressRight;
imageElements{2, 2}.ImageClickedFcn = @regionCompressor.compressIn;
imageElements{2, 3}.ImageClickedFcn = @regionCompressor.compressLeft;

imageElements{3, 1}.ImageClickedFcn = @regionCompressor.compressUpRight;
imageElements{3, 2}.ImageClickedFcn = @regionCompressor.compressUp;
imageElements{3, 3}.ImageClickedFcn = @regionCompressor.compressUpLeft;
end
