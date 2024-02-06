classdef ImportImage
    properties (Access = private)
        pixelRegion;
    end

    methods
        function obj = ImportImage(rectangle)
            position = rectangle.Position;
            xmin = position(1);
            xmax = xmin + position(3);
            ymin = position(2);
            ymax = ymin + position(4);

            obj.pixelRegion = {[ymin ymax], [xmin, xmax]};
        end

        function im = get(obj, filepath)
            im = imread( ...
                filepath, ...
                "PixelRegion", obj.pixelRegion ...
                );
        end
    end

end