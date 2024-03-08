classdef ImageInverter
    properties
        invert;
        intensity;
    end

    methods
        function obj = ImageInverter(invert, maxIntensity)
            obj.invert = invert;
            obj.intensity = maxIntensity;
        end

        function im = get(obj, im)
            if obj.invert
                im = obj.intensity - im;
            end
        end
    end
end