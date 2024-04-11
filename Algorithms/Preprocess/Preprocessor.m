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

    methods (Static)
        function processor = fromRegion(region)
            regionUserData = RegionUserData.fromRegion(region);
            thresholds = regionUserData.getThresholds();
            invert = regionUserData.getInvert();
            processor = Preprocessor(thresholds, invert);
        end
    end
end

function processor = generateNoiseRemover(thresholds)
noiseRemover = NoiseRemover(thresholds);
processor = @noiseRemover.get;
end

function processor = generateImageInverter(invert)
imageInverter = ImageInverter(invert);
processor = @imageInverter.get;
end