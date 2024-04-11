classdef ImageInverter
    properties
        invert;
    end

    methods
        function obj = ImageInverter(invert)
            obj.invert = invert;
        end

        function im = get(obj, im)
            if obj.invert
                im = imcomplement(im);
            end
        end
    end
end