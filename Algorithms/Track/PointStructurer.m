classdef PointStructurer
    properties
        point;
    end
    
    properties (Constant)
        xMeanLabel = "x";
        yMeanLabel = "y";
        xErrorLabel = "xError";
        yErrorLabel = "yError";
    end

    methods
        function obj = PointStructurer(point)
            obj.point = point;
        end

        function x = getX(obj)
            x = obj.point.(PointStructurer.xMeanLabel);
        end
        function y = getY(obj)
            y = obj.point.(PointStructurer.yMeanLabel);
        end
        function xstd = getErrorX(obj)
            xstd = obj.point.(PointStructurer.xErrorLabel);
        end
        function ystd = getErrorY(obj)
            ystd = obj.point.(PointStructurer.yErrorLabel);
        end
    end

    methods (Static)
        function merged = mergePoints(points)
            fields = fieldnames(points);
            for index = 1:numel(fields)
                field = fields{index};
                merged.(field) = [points.(field)];
            end
        end

        function point = asPoint(xmean, ymean, xerr, yerr)
            point = struct( ...
                PointStructurer.xMeanLabel, xmean, ...
                PointStructurer.yMeanLabel, ymean, ...
                PointStructurer.xErrorLabel, xerr, ...
                PointStructurer.yErrorLabel, yerr ...
                );
        end

        function points = preallocate(count)
            point = PointStructurer.asPoint(0, 0, 0, 0);
            fields = fieldnames(point);
            points = struct();
            for index = 1:numel(fields)
                field = fields{index};
                points.(field) = zeros(1, count);
            end
        end
    end
end