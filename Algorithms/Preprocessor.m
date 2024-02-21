classdef Preprocessor
    properties (Access = private)
        removeNoise;
        invertImage
    end

    methods
        function obj = Preprocessor(thresholds, invert)
            obj.removeNoise = generateNoiseRemover(thresholds);
            obj.invertImage = generateImageInverter(invert);
        end

        function im = preprocess(obj, im)
            im = obj.removeNoise(im);
            im = obj.invertImage(im);
        end
    end
end

function processor = generateNoiseRemover(thresholds)
minThreshold = thresholds(1);
maxThreshold = thresholds(2);
noiseRemover = NoiseRemover(minThreshold, maxThreshold);
processor = @noiseRemover.get;
end

function processor = generateImageInverter(invert)
imageInverter = ImageInverter(invert, 1);
processor = @imageInverter.get;
end