classdef PlotFromTraceArray
    methods (Static)
        function waterfall(traces, varargin)
            p = inputParser;
            addOptional(p, "Offset", 100);
            parse(p, varargin{:});
            offset = p.Results.Offset;

            traceCount = height(traces);

            title("Waterfall Plot of Bundle Position");
            xlabel("Time [frames]")
            ylabel("Position [nm]");

            hold on;
            for index = 1:traceCount
                trace = traces(index, :);
                traceOffset = offset * (index - 1);
                plot(trace + traceOffset);
            end
            hold off;
        end
    end
end