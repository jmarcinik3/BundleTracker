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
    @compressor.compressUpLeft, @compressor.compressUp, @compressor.compressUpRight, ...
    @compressor.compressLeft, @compressor.compressOut, @compressor.compressRight, ...
    @compressor.compressDownLeft, @compressor.compressDown, @compressor.compressDownRight ...
    };
callbacks = reshape(callbacks, 3, 3);
end
