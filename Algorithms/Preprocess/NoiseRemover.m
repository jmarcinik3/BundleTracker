classdef NoiseRemover
    properties
        minimumIntensity;
        maximumIntensity;
    end
    
    methods
        function obj = NoiseRemover(minThresh, maxThresh)
            obj.minimumIntensity = minThresh;
            obj.maximumIntensity = maxThresh;
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