classdef ResultsParser
    properties
        results;
    end

    methods
        function obj = ResultsParser(results)
            if isstring(results)
                obj.results = load(results, "results").results;
            elseif isstruct(results)
                obj.results = results;
            end
        end

        function count = getRegionCount(obj)
            count = numel(obj.results);
        end
        function label = getLabel(obj)
            label = vertcat(obj.results.Label);
        end

        function time = getTime(obj)
            time = vertcat(obj.results.t);
        end
        function trace = getProcessedTrace(obj)
            trace = vertcat(obj.results.xProcessed);
        end
        function error = getProcessedTraceError(obj)
            error = vertcat(obj.results.xProcessedError);
        end
        function trace = getProcessedTrace2(obj)
            trace = vertcat(obj.results.yProcessed);
        end
        function trace = getProcessedTraceError2(obj)
            trace = vertcat(obj.results.yProcessedError);
        end

        function x = getRawTraceX(obj)
            x = vertcat(obj.results.x);
        end
        function y = getRawTraceY(obj)
            y = vertcat(obj.results.y);
        end
        function error = getRawTraceErrorX(obj)
            error = vertcat(obj.results.xError);
        end
        function error = getRawTraceErrorY(obj)
            error = vertcat(obj.results.yError);
        end

        function angle = getAngleRadians(obj)
            angle = vertcat(obj.results.angle);
        end
        function angle = getAngleDegrees(obj)
            angleRad = obj.getAngleRadians();
            angle = rad2deg(angleRad);
        end
        function error = getAngleErrorRadians(obj)
            error = vertcat(obj.results.angleError);
        end
        function error = getAngleErrorDegrees(obj)
            errorRad = obj.getAngleErrorRadians();
            error = rad2deg(errorRad);
        end

        function trackingMode = getTrackingMode(obj)
            trackingMode = vertcat(obj.results.TrackingMode);
        end
        function location = getPositiveDirection(obj)
            location = vertcat(obj.results.Direction);
        end
        function fps = getFps(obj)
            fps = obj.results.Fps;
        end
        function is = pixelsAreInverted(obj)
            is = vertcat(obj.results.IsInverted);
        end
        function intensities = getIntensityRange(obj)
            intensities = vertcat(obj.results.IntensityRange);
        end
    end
end