classdef ResultsParser
    properties
        filepath;
        results;
    end

    methods
        function obj = ResultsParser(filepath)
            obj.filepath = filepath;
            obj.results = load(filepath, "results").results;
        end

        function time = getTime(obj)
            time = obj.results.t;
        end
        function trace = getProcessedTrace(obj)
            trace = obj.results.xProcessed;
        end
        function error = getProcessedTraceError(obj)
            error = obj.results.xProcessedError;
        end
        function trace = getProcessedTrace2(obj)
            trace = obj.results.yProcessed;
        end
        function trace = getProcessedTraceError2(obj)
            trace = obj.results.yProcessedError;
        end

        function x = getRawTraceX(obj)
            x = obj.results.x;
        end
        function y = getRawTraceY(obj)
            y = obj.results.y;
        end
        function error = getRawTraceErrorX(obj)
            error = obj.results.xError;
        end
        function error = getRawTraceErrorY(obj)
            error = obj.results.yError;
        end

        function angle = getAngleRadians(obj)
            angle = obj.results.angle;
        end
        function angle = getAngleDegrees(obj)
            angleRad = obj.getAngleRadians();
            angle = rad2deg(angleRad);
        end
        function error = getAngleErrorRadians(obj)
            error = obj.results.angleError;
        end
        function error = getAngleErrorDegrees(obj)
            errorRad = obj.getAngleErrorRadians();
            error = rad2deg(errorRad);
        end

        function location = getKinociliumLocation(obj)
            location = obj.results.KinociliumLocation;
        end
        function fps = getFps(obj)
            fps = obj.results.Fps;
        end
        function is = pixelsAreInverted(obj)
            is = obj.results.IsInverted;
        end
        function intensities = getIntensityRange(obj)
            intensities = obj.results.IntensityRange;
        end
        function bounds = getRegionBounds(obj)
            bounds = obj.results.Bounds;
        end
    end

    methods (Static)
        function trace = traceArrayFromFilepath(filepath)
            resultsParser = ResultsParser(filepath);
            trace = resultsParser.getProcessedTrace();
        end

        function traces = traceArrayFromFilepaths(filepaths)
            firstFilepath = filepaths(1);
            firstTrace = ResultsParser.traceArrayFromFilepath(firstFilepath);
            traceCount = numel(filepaths);
            traceSize = numel(firstTrace);

            traces = zeros(traceCount, traceSize);
            traces(1, :) = firstTrace;
            for index = 2:traceCount
                newFilepath = filepaths(index);
                newTrace = ResultsParser.traceArrayFromFilepath(newFilepath);
                traces(index, :) = newTrace;
            end
        end
    end
end