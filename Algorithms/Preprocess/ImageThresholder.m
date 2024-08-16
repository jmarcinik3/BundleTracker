classdef ImageThresholder
    properties
        minimumIntensity;
        maximumIntensity;
    end

    methods
        function obj = ImageThresholder(thresholds)
            obj.minimumIntensity = thresholds(1);
            obj.maximumIntensity = thresholds(2);
        end

        function ims = get(obj, ims)
            minIntensity = obj.minimumIntensity;
            maxIntensity = obj.maximumIntensity;
            ims = normalizeImage(ims, [minIntensity, maxIntensity]);
        end
    end
end