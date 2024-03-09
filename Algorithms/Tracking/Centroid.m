classdef Centroid
    properties (Access = private)
        x;
        y;
        weights;

        wx;
        wy;
        wxx;
        wyy;
    end

    methods
        function obj = Centroid(im)
            [x, y] = calculateXY(im);
            weights = calculateWeights(im);

            wx = weights .* x;
            wy = weights .* y;
            obj.wxx = wx .* x;
            obj.wyy = wy .* y;
            
            obj.x = x;
            obj.y = y;
            obj.weights = weights;
            obj.wx = wx;
            obj.wy = wy;
        end

        function center = withError(obj)
            xmean = sum(obj.wx, "all");
            ymean = sum(obj.wy, "all");
            [xerr, yerr] = obj.bootstrapError();
            center = PointStructurer.asPoint(xmean, ymean, xerr, yerr);
        end
    end

    methods (Access = private)
        function [xerr, yerr] = bootstrapError(obj)
            x = obj.x;
            y = obj.y;
            [rows, columns] = size(x);

            count = min(round(sqrt(rows * columns)), 16);
            xmeans = 0 * ones(1, count);
            ymeans = 0 * ones(1, count);
            xstds = 0 * ones(1, count);
            ystds = 0 * ones(1, count);
            
            wxFull = obj.wx;
            wyFull = obj.wy;
            wxxFull = obj.wxx;
            wyyFull = obj.wyy;

            for index = 1:count
                [newMask, newArea] = obj.generateWeights();
                xnew = sum(wxFull(newMask), "all") / newArea;
                ynew = sum(wyFull(newMask), "all") / newArea;

                xmeans(index) = xnew;
                ymeans(index) = ynew;
                xstds(index) = sqrt(sum(wxxFull(newMask), "all") / newArea - xnew^2);
                ystds(index) = sqrt(sum(wyyFull(newMask), "all") / newArea - ynew^2);
            end

            xerr = std(xmeans, 1 ./ (xstds.^2));
            yerr = std(ymeans, 1 ./ (ystds.^2));
        end

        function [randomMask, newArea] = generateWeights(obj)
            [rows, columns] = size(obj.x);
            weights = obj.weights;
            newArea = 0;

            while newArea == 0
                randomMask = rand(rows, columns) > weights;
                weights(~randomMask) = 0;
                newArea = sum(weights, "all");
            end
        end
    end
end



function [x, y] = calculateXY(im)
[rows, columns] = size(im);
x = ones(rows, 1) * (1:columns); % 2D matrix of x indicies
y = (1:rows)' * ones(1, columns); % 2D matrix of y indicies
end

function weights = calculateWeights(im)
intensity = double(im);
area = sum(intensity, "all");
weights = intensity / area;
end
