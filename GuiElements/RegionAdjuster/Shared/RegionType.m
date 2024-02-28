classdef RegionType      
    methods (Static)
        function is = isRectangle(region)
            is = isa(region, "images.roi.Rectangle");
        end
        function is = isEllipse(region)
            is = isa(region, "images.roi.Ellipse");
        end
        function is = isPolygon(region)
            is = isa(region, "images.roi.Polygon");
        end
        function is = isFreehand(region)
            is = isa(region, "images.roi.Freehand");
        end

        function is = hasPointPosition(region)
            is = RegionType.isRectangle(region) ...
                || RegionType.isEllipse(region);
        end
        function is = hasVertexPosition(region)
            is = RegionType.isPolygon(region) ...
                || RegionType.isFreehand(region);
        end
    end
end

