classdef Centroid
    properties (Access = private)
        intensity2error;
        xy;
    end

    methods
        function obj = Centroid(ims)
            obj.intensity2error = calculateIntensityToError(ims);
            [rows, columns] = size(ims, [1, 2]);
            x = ones(rows, 1) * (1:columns); % 2D matrix of x indicies
            y = (1:rows)' * ones(1, columns); % 2D matrix of y indicies
            obj.xy = cat(3, x, y);
        end

        function center = centerWithError(obj, im)
            imError = obj.intensity2error(im);
            imageWithError = ErrorPropagator(im, imError);
            weights = imageWithError ./ sum(imageWithError, "all");
            xyMean = sum(weights .* obj.xy, [1, 2]);

            center = PointStructurer.asPoint( ...
                xyMean.Value(1), ...
                xyMean.Value(2), ...
                xyMean.Error(1), ...
                xyMean.Error(2) ...
                );
        end
    end
end



function intensity2error = calculateIntensityToError(ims)
xyMean = mean(ims, 3);
xyStd = std(ims, [], 3);

xyValid = xyMean > 0 & xyStd > 0;
xyMeanLog = log(xyMean(xyValid));
xyStdLog = log(xyStd(xyValid));

mdl = fitlm(xyMeanLog, xyStdLog);
intercept = mdl.Coefficients.Estimate(1);
slope = mdl.Coefficients.Estimate(2);
A = exp(intercept);
intensity2error = @(x) A * x.^slope;
end
