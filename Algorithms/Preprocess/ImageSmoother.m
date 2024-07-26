classdef ImageSmoother
    properties
        width;
    end

    methods
        function obj = ImageSmoother(width)
            obj.width = width;
        end

        function im = get(obj, im)
            width = obj.width;
            if width > 0
                im = smoothdata2(im, "movmean", width);
            end
        end
    end
end