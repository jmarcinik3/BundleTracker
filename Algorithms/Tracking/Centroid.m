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

            obj.wxx = wx .* x;
            obj.wyy = wy .* y;
            obj.rows = rows;
            obj.columns = columns;
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

            wx = obj.wx;
            wy = obj.wy;
            wxx = obj.wxx;
            wyy = obj.wyy;

            rows = obj.rows;
            columns = obj.columns;
            weights = obj.weights;

            for index = 1:count
                [mask, area] = generateWeights(weights, rows, columns);
                [xmean, ymean, xstd, ystd] = centroidFromWXY( ...
                    area, wx(mask), wy(mask), wxx(mask), wyy(mask) ...
                    );
                xy(:, index) = [xmean, ymean, xstd, ystd];
            end

            xymeans = xy(1:2, :);
            xystds = xy(3:4, :);
            xerr = std(xymeans(1), 1 ./ (xystds(1).^2));
            yerr = std(xymeans(2), 1 ./ (xystds(2).^2));
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

function [xmean, ymean, xstd, ystd] = centroidFromWXY(area, wx, wy, wxx, wyy)
xmean = sum(wx, "all") / area;
ymean = sum(wy, "all") / area;
xstd = sqrt(sum(wxx, "all") / area - xmean^2);
ystd = sqrt(sum(wyy, "all") / area - ymean^2);
end

function [randomMask, newArea] = generateWeights(weights, rows, columns)
newArea = 0;
while newArea == 0
    randomMask = rand(rows, columns) > weights;
    weights(~randomMask) = 0;
    newArea = sum(weights, "all");
end
end
