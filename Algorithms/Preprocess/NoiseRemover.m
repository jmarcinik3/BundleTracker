classdef NoiseRemover
    properties
        minimumIntensity;
        maximumIntensity;
    end
    
    methods
        function obj = NoiseRemover(thresholds)
            obj.minimumIntensity = thresholds(1);
            obj.maximumIntensity = thresholds(2);
        end

        function im = get(obj, im)
            minIntensity = obj.minimumIntensity;
            maxIntensity = obj.maximumIntensity;
            im(im < minIntensity) = minIntensity;
            im(im > maxIntensity) = maxIntensity;
            im = mat2gray(im);
        end

    end
end