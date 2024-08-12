classdef Preprocessor
    properties (Access = private)
        smoothImage;
        thresholdImage;
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
            imageThresholder = ImageThresholder(thresholds);
            imageInverter = ImageInverter(invert);

            obj.smoothImage = @imageSmoother.get;
            obj.thresholdImage = @imageThresholder.get;
            obj.invertImage = @imageInverter.get;
        end

        function ims = preThreshold(obj, ims)
            ims = obj.smoothImage(ims);
            ims = normalizeImage(ims);
        end

        function ims = preprocess(obj, ims)
            ims = obj.preThreshold(ims);
            ims = obj.thresholdImage(ims);
            ims = normalizeImage(ims);
            ims = obj.invertImage(ims);
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



function ims = normalizeImage(ims)
if ismatrix(ims)
    ims = mat2gray(ims);
    return;
end

for index = 1:size(ims, 3)
    ims(:, :, index) = mat2gray(ims(:, :, index));
end
end