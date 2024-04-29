classdef Centroid
    properties (Access = private)
        weights;
        bootstrapCount;

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

            obj.weights = weights;
            obj.wx = wx;
            obj.wy = wy;
            obj.wxx = wx .* x;
            obj.wyy = wy .* y;
            obj.bootstrapCount = min(round(sqrt(rows * columns)), 8);
        end

        function [xmean, ymean] = calculateMean(obj)
            xmean = sum(obj.wx, "all");
            ymean = sum(obj.wy, "all");
        end

        function center = withError(obj)
            bootstrapCount = obj.bootstrapCount;
            [xmean, ymean] = obj.calculateMean();
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
            weights = obj.weights;

            for index = 1:count
                [mask, area] = generateWeights(weights);
                [xmean, ymean, xstd, ystd] = centroidFromWXY( ...
                    area, wx(mask), wy(mask), wxx(mask), wyy(mask) ...
                    );
                xy(:, index) = [xmean, ymean, xstd, ystd];
            end

            xymeans = xy(1:2, :);
            xystds = xy(3:4, :);
            xyw = 1 ./ xystds.^2;
            xyw = xyw ./ sum(xyw, 2);
            xym = xyw .* xymeans;
            
            discriminant = sum(xym .* xymeans, 2) - sum(xym, 2).^2;
            xyerr = sqrt(abs(discriminant));
            xerr = xyerr(1);
            yerr = xyerr(2);
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

function [randomMask, newArea] = generateWeights(weights)
[rows, columns] = size(weights);
newArea = 0;
while newArea == 0
    randomMask = rand(rows, columns) > weights;
    weights(~randomMask) = 0;
    newArea = sum(weights, "all");
end
end
