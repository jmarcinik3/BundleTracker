classdef Preprocessor
    properties (Access = private)
        smoothImage;
        removeNoise;
        invertImage;
    end

    methods
        function obj = Preprocessor(varargin)
            p = inputParser;
            addOptional(p, "Smoothing", 0);
            addOptional(p, "Thresholds", [0, 1]);
            addOptional(p, "Invert", 0);
            parse(p, varargin{:});

            smoothing = p.Results.Smoothing;
            thresholds = p.Results.Thresholds;
            invert = p.Results.Invert;

            imageSmoother = ImageSmoother(smoothing);
            noiseRemover = NoiseRemover(thresholds);
            imageInverter = ImageInverter(invert);

            obj.smoothImage = @imageSmoother.get;
            obj.removeNoise = @noiseRemover.get;
            obj.invertImage = @imageInverter.get;
        end

        function im = preThreshold(obj, im)
            im = obj.smoothImage(im);
            im = mat2gray(im);
        end

        function im = preprocess(obj, im)
            im = obj.preThreshold(im);
            im = obj.removeNoise(im);
            im = obj.invertImage(im);
        end
    end

    methods (Static)
        function processor = fromRegion(region)
            regionUserData = RegionUserData(region);
            processor = Preprocessor( ...
                "Smoothing", regionUserData.getSmoothing(), ...
                "Thresholds", regionUserData.getThresholds(), ...
                "Invert", regionUserData.getInvert() ...
                );
        end
    end
end
