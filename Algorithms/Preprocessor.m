classdef Preprocessor
    properties
        thresholds;
        invert;
    end

    methods
        function obj = Preprocessor(thresholds, invert)
            obj.thresholds = thresholds;
            obj.invert = invert;
        end

        function im = get(obj, im)
            im = obj.removeNoise(im);
            im = obj.invertImage(im);
        end

        function im = removeNoise(obj, im)
            removeN = obj.getNoiseRemover();
            im = removeN(im);
        end

        function im = invertImage(obj, im)
            processInvert = obj.getInverter();
            im = processInvert(im);
        end
    end

    methods (Access = private)
        function processor = getNoiseRemover(obj)
            threshs = obj.thresholds;
            minThresh = threshs(1);
            maxThresh = threshs(2);

            noiseRemover = NoiseRemover(minThresh, maxThresh);
            processor = @noiseRemover.get;
        end

        function processor = getInverter(obj)
            inv = obj.invert;
            inverter = ImageInverter(inv, 1);
            processor = @inverter.get;
        end
    end
end