classdef ResultsParser
    properties (Access = private)
        results;
        metadata;
    end

    methods
        function obj = ResultsParser(results)
            if isstring(results) || ischar(results)
                results = load(results);
                obj.results = results.results;
                if isfield(results, "metadata")
                    obj.metadata = results.metadata;
                end
            elseif isstruct(results)
                if isfield(results, "metadata")
                    obj.results = results.results;
                    obj.metadata = results.metadata;
                    return;
                end
                obj.results = results;
            elseif isa(results, "ResultsParser")
                obj = results;
            end
        end

        function frame = getFirstFrame(obj, index)
            frame = obj.metadata.FirstFrame;
            if nargin > 1
                regionInfo = obj.getRegion(index);

                ax = gca;
                region = drawRegionByInfo(ax, regionInfo);
                region.UserData = RegionUserData();
                RegionUserData.configureByResultsParser(region, obj, index);
                regionalImage = generateRegionalImages(region, frame);
                close(ancestor(ax, "figure"));

                frame = regionalImage{1};
            end
        end

        function result = getResult(obj, index)
            result = obj.results;
            if nargin > 1
                result = result(index);
            end
        end
        function count = getRegionCount(obj)
            count = numel(obj.results);
        end
        function region = getRegion(obj, index)
            results = obj.results;
            regionCount = obj.getRegionCount();
            region = arrayfun( ...
                @(index) results(index).Region, ...
                1:regionCount, ...
                "UniformOutput", false ...
                );
            if nargin > 1
                region = region{index};
            end
        end
        function label = getLabel(obj, index)
            label = vertcat(obj.results.Label);
            if nargin > 1
                label = label(index);
            end
        end

        function time = getTime(obj)
            time = obj.results.t;
        end
        function trace = getProcessedTrace(obj, index)
            trace = vertcat(obj.results.xProcessed);
            if nargin > 1
                trace = trace(index, :);
            end
        end
        function error = getProcessedTraceError(obj, index)
            error = vertcat(obj.results.xProcessedError);
            if nargin > 1
                error = error(index, :);
            end
        end
        function trace = getProcessedTrace2(obj, index)
            trace = vertcat(obj.results.yProcessed);
            if nargin > 1
                trace = trace(index, :);
            end
        end
        function trace = getProcessedTraceError2(obj, index)
            trace = vertcat(obj.results.yProcessedError);
            if nargin > 1
                trace = trace(index, :);
            end
        end

        function x = getRawTraceX(obj, index)
            x = vertcat(obj.results.x);
            if nargin > 1
                x = x(index, :);
            end
        end
        function y = getRawTraceY(obj, index)
            y = vertcat(obj.results.y);
            if nargin > 1
                y = y(index, :);
            end
        end
        function error = getRawTraceErrorX(obj, index)
            error = vertcat(obj.results.xError);
            if nargin > 1
                error = error(index, :);
            end
        end
        function error = getRawTraceErrorY(obj, index)
            error = vertcat(obj.results.yError);
            if nargin > 1
                error = error(index, :);
            end
        end

        function angle = getAngleRadians(obj, index)
            angle = vertcat(obj.results.angle);
            if nargin > 1
                angle = angle(index, :);
            end
        end
        function angle = getAngleDegrees(obj, index)
            if nargin > 1
                angleRad = obj.getAngleRadians(index);
            else
                angleRad = obj.getAngleRadians();
            end
            angle = rad2deg(angleRad);
        end
        function error = getAngleErrorRadians(obj, index)
            error = vertcat(obj.results.angleError);
            if nargin > 1
                error = error(index, :);
            end
        end
        function error = getAngleErrorDegrees(obj, index)
            if nargin > 1
                errorRad = obj.getAngleErrorRadians(index);
            else
                errorRad = obj.getAngleErrorRadians();
            end
            error = rad2deg(errorRad);
        end
        function info = getAngleInfo(obj, index)
            info = vertcat(obj.results.angleInfo);
            if nargin > 1
                info = info(index, :);
            end
        end

        function area = getAreaPixels(obj, index)
            area = vertcat(obj.results.Area);
            if nargin > 1
                area = area(index, :);
            end
        end
        function error = getAreaErrorPixels(obj, index)
            error = vertcat(obj.results.AreaError);
            if nargin > 1
                error = error(index, :);
            end
        end
        function area = getArea(obj, index)
            if nargin < 2
                index = 1:obj.getRegionCount();
            end

            areaPixels = ErrorPropagator( ...
                obj.getAreaPixels(index), ...
                obj.getAreaErrorPixels(index) ...
                );
            scaleFactor = ErrorPropagator( ...
                obj.getScaleFactor(), ...
                obj.getScaleFactorError() ...
                );
            areaWithError = areaPixels * scaleFactor.^2;
            area = areaWithError.Value;
        end
        function error = getAreaError(obj, index)
            if nargin < 2
                index = 1:obj.getRegionCount();
            end

            areaPixels = ErrorPropagator( ...
                obj.getAreaPixels(index), ...
                obj.getAreaErrorPixels(index) ...
                );
            scaleFactor = ErrorPropagator( ...
                obj.getScaleFactor(), ...
                obj.getScaleFactorError() ...
                );
            areaWithError = areaPixels * scaleFactor.^2;
            error = areaWithError.Error;
        end

        function trackingMode = getTrackingMode(obj, index)
            trackingMode = vertcat(obj.results.TrackingMode);
            if nargin > 1
                trackingMode = trackingMode(index, :);
            end
        end
        function angleMode = getAngleMode(obj, index)
            angleMode = vertcat(obj.results.AngleMode);
            if nargin > 1
                angleMode = angleMode(index, :);
            end
        end
        function detrendMode = getDetrendMode(obj, index)
            detrendMode = vertcat(obj.results.DetrendMode);
            if nargin > 1
                detrendMode = detrendMode(index, :);
            end
        end
        function location = getPositiveDirection(obj, index)
            location = vertcat(obj.results.Direction);
            if nargin > 1
                location = location(index, :);
            end
        end
        function fps = getFps(obj)
            fps = obj.results.Fps;
        end
        function is = pixelsAreInverted(obj, index)
            is = vertcat(obj.results.IsInverted);
            if nargin > 1
                is = is(index, :);
            end
        end
        function intensities = getSmoothingWidth(obj, index)
            intensities = vertcat(obj.results.Smoothing);
            if nargin > 1
                intensities = intensities(index, :);
            end
        end
        function intensities = getIntensityRange(obj, index)
            intensities = vertcat(obj.results.IntensityRange);
            if nargin > 1
                intensities = intensities(index, :);
            end
        end

        function scaleFactor = getScaleFactor(obj)
            scaleFactor = obj.results.ScaleFactor;
        end
        function scaleFactor = getScaleFactorError(obj)
            scaleFactor = obj.results.ScaleFactorError;
        end
    end
end