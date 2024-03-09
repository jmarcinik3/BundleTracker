classdef Centroid
    properties (Access = private)
        weights;
        rows;
        columns;

        wx; % weights.*x
        wy; % weights.*y
        wxx; % weights.*x.^2
        wyy; % weights.*y.^2
    end

    methods
        function obj = Centroid(im)
            [rows, columns] = size(im);
            [x, y] = calculateXY(rows, columns);
            weights = calculateWeights(im);

            wx = weights .* x;
            wy = weights .* y;

            obj.rows = rows;
            obj.columns = columns;
            obj.wxx = wx .* x;
            obj.wyy = wy .* y;
            obj.weights = weights;
            obj.wx = wx;
            obj.wy = wy;
        end

        function center = withError(obj)
            rows = obj.rows;
            columns = obj.columns;
            bootstrapCount = min(round(sqrt(rows * columns)), 8);

            xmean = sum(obj.wx, "all");
            ymean = sum(obj.wy, "all");
            [xerr, yerr] = obj.bootstrapError(bootstrapCount);
            center = PointStructurer.asPoint(xmean, ymean, xerr, yerr);
        end
    end

    methods (Access = private)
        function [xerr, yerr] = bootstrapError(obj, count)
            xy = zeros(4, count);

            for index = 1:count
                [xmean, ymean, xstd, ystd] = obj.bootstrap();
                xy(:, index) = [xmean, ymean, xstd, ystd];
            end
            
            xymeans = xy(1:2, :);
            xystds = xy(3:4, :);
            xerr = std(xymeans(1), 1 ./ (xystds(1).^2));
            yerr = std(xymeans(2), 1 ./ (xystds(2).^2));
        end

        function [randomMask, newArea] = generateWeights(obj)
            rows = obj.rows;
            columns = obj.columns;
            weights = obj.weights;
            newArea = 0;

            while newArea == 0
                randomMask = rand(rows, columns) > weights;
                weights(~randomMask) = 0;
                newArea = sum(weights, "all");
            end
        end

        function [xmean, ymean, xstd, ystd] = bootstrap(obj)
            [mask, area] = obj.generateWeights();
            xmean = sum(obj.wx(mask), "all") / area;
            ymean = sum(obj.wy(mask), "all") / area;
            xstd = sqrt(sum(obj.wxx(mask), "all") / area - xmean^2);
            ystd = sqrt(sum(obj.wyy(mask), "all") / area - ymean^2);
        end
    end
end



function [x, y] = calculateXY(rows, columns)
x = ones(rows, 1) * (1:columns); % 2D matrix of x indicies
y = (1:rows)' * ones(1, columns); % 2D matrix of y indicies
end

function weights = calculateWeights(im)
intensity = double(im);
area = sum(intensity, "all");
weights = intensity / area;
end
