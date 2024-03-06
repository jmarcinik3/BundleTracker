classdef RegionCompressorLinker < RegionAdjusterLinker
    methods
        function obj = RegionCompressorLinker(gui, region)
            regionCompressor = RegionCompressor(region);
            callbacks = generateCallbacks(regionCompressor);
            obj@RegionAdjusterLinker(gui, callbacks);
        end
    end
end



function callbacks = generateCallbacks(compressor)
callbacks = {
    @compressor.compressDownRight, @compressor.compressDown, @compressor.compressDownLeft, ...
    @compressor.compressRight, @compressor.compressIn, @compressor.compressLeft, ...
    @compressor.compressUpRight, @compressor.compressUp, @compressor.compressUpLeft ...
    };
callbacks = reshape(callbacks, 3, 3)';
end
