classdef ResultsParser < handle
    properties (Constant)
        extensions = {'*.mat', "MATLAB Structure"};
    end

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
    end

    %% Functions to generate parser inputs
    methods (Static)
        function resultsParser = fromSeparate(results, metadata)
            resultsStruct = struct( ...
                "results", results, ...
                "metadata", metadata ...
                );
            resultsParser = ResultsParser(resultsStruct);
        end
    end

    %% Functions to set state information
    methods
        function export(obj, filepath)
            results = obj.results;
            metadata = obj.metadata;
            save(filepath, "results", "metadata");
            fprintf( ...
                "Results saved to %s (%d traces)\n", ...
                filepath, ...
                obj.getRegionCount() ...
                );
        end

        function setProcessedTrace(obj, trace, index)
            obj.results(index).xProcessed = trace;
        end
        function setProcessedTraceError(obj, error, index)
            obj.results(index).xProcessedError = error;
        end
        function setProcessedTrace2(obj, trace, index)
            obj.results(index).yProcessed = trace;
        end
        function setProcessedTraceError2(obj, error, index)
            obj.results(index).yProcessedError = error;
        end

        function setAngleRadians(obj, angle, index)
            obj.results(index).angle = angle;
        end
        function setAngleErrorRadians(obj, error, index)
            obj.results(index).angleError = error;
        end
        function setAngleMode(obj, angleMode, index)
            obj.results(index).AngleMode = angleMode;
        end
        function setAngleInfo(obj, info, index)
            obj.results(index).angleInfo = info;
        end

        function setDetrendMode(obj, detrendMode, index)
            obj.results(index).DetrendMode = detrendMode;
        end
        function setDetrendInfo(obj, info, index)
            obj.results(index).detrendInfo = info;
        end
    end

    %% Functions to append postprocessing
    methods
        function rerotateTrace(obj, newAngle, index)
            initialAngle = obj.getAngleRadians(index);
            if abs(newAngle - initialAngle) <= 1e-9
                return;
            end

            x = obj.getProcessedTrace(index);
            y = obj.getProcessedTrace2(index);
            xerr = obj.getProcessedTraceError(index);
            yerr = obj.getProcessedTraceError2(index);
            [xRotated, yRotated] = TraceRotator.rotate2d( ...
                ErrorPropagator(x, xerr), ...
                ErrorPropagator(y, yerr), ...
                newAngle - initialAngle ...
                );

            obj.setProcessedTrace(xRotated.Value, index);
            obj.setProcessedTrace2(yRotated.Value, index);
            obj.setProcessedTraceError(xRotated.Error, index);
            obj.setProcessedTraceError2(yRotated.Error, index);
            obj.setAngleRadians(newAngle, index);
            obj.setAngleErrorRadians(0, index);
            obj.setAngleMode("None", index);
            obj.setAngleInfo([], index);
        end
        function redetrendTrace(obj, windowSize, windowName, index)
            x = obj.getProcessedTrace(index);
            y = obj.getProcessedTrace2(index);

            function trace = detrendTrace(trace)
                trace = detrend(trace, 1);
                ma = MovingAverage.averageByKeyword(trace, windowSize, windowName);
                trace = trace - ma;
            end
            
            xDetrend = detrendTrace(x);
            yDetrend = detrendTrace(y);

            detrendInfo = struct( ...
                "PolynomialPower", 1, ...
                "WindowSize", windowSize, ...
                "WindowShape", windowName ...
                );
            detrendMode = [ ...
                DetrendAlgorithms.polyKeyword, ...
                DetrendAlgorithms.movingAverageKeyword ...
                ];

            obj.setProcessedTrace(xDetrend, index);
            obj.setProcessedTrace2(yDetrend, index);
            obj.setDetrendMode(detrendMode, index);
            obj.setDetrendInfo(detrendInfo, index);
        end
    end

    %% Functions to retrieve state information
    methods
        function frame = getFirstFrame(obj, index)
            frame = obj.metadata.FirstFrame;
            if nargin > 1
                regionInfo = obj.getRegion(index);
                
                fig = figure();
                ax = axes(fig);
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
            areaWithError = areaPixels .* scaleFactor.^2;
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
            areaWithError = areaPixels .* scaleFactor.^2;
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