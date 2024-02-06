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
            xMeanLabel = PointStructurer.xMeanLabel;
            yMeanLabel = PointStructurer.yMeanLabel;
            xErrorLabel = PointStructurer.xErrorLabel;
            yErrorLabel = PointStructurer.yErrorLabel;
            
            merged.(xMeanLabel) = [points.(xMeanLabel)];
            merged.(yMeanLabel) = [points.(yMeanLabel)];
            merged.(xErrorLabel) = [points.(xErrorLabel)];
            merged.(yErrorLabel) = [points.(yErrorLabel)];
        end

        function point = asPoint(xmean, ymean, xerr, yerr)
            point = struct( ...
                PointStructurer.xMeanLabel, xmean, ...
                PointStructurer.yMeanLabel, ymean, ...
                PointStructurer.xErrorLabel, xerr, ...
                PointStructurer.yErrorLabel, yerr ...
                );
        end
    end
end