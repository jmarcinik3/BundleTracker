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