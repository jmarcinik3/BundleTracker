classdef DetrenderLinker < handle
    properties
        gui;
        axWindow;
        resultsParser;
        traceLines;
        trendLines;
        traceScatters;
        resultsDirectory = "";
    end

    methods
        function obj = DetrenderLinker(gui, filepath)
            [obj.resultsDirectory, ~, ~] = fileparts(filepath);
            resultsParser = ResultsParser(filepath);
            t = resultsParser.getTime();
            x = resultsParser.getProcessedTrace();

            axWindow = AxisWindow(gui.getWindowAxis(), 2*numel(t));
            addlistener(axWindow, "WindowSize", "PostSet", @obj.updateDisplay);
            addlistener(axWindow, "WindowName", "PostSet", @obj.updateDisplay);

            traceLines = Waterfall.plotOnAxis(gui.getTraceAxis(), zeros(size(x)), t);
            trendLines = Waterfall.plotOnAxis(gui.getTrendAxis(), zeros(size(x)), t);
            traceScatters = scatter( ...
                gui.getTraceAxis2d(), ...
                zeros(size(x.')), ...
                zeros(size(x.')), ...
                "Marker", '.', ...
                "SizeData", 10 ...
                );

            set( ...
                gui.getTrendAxis(), ...
                "YLim", max(abs(x), [], "all") * [-1, 1] ...
                );

            fig = gui.getFigure();
            DetrenderMenu(fig, obj);

            obj.gui = gui;
            obj.axWindow = axWindow;
            obj.resultsParser = resultsParser;
            obj.traceLines = traceLines;
            obj.trendLines = trendLines;
            obj.traceScatters = traceScatters;
            obj.updateDisplay();
        end
    end

    %% Functions to update state of GUI
    methods
        function exportButtonPushed(obj, ~, ~)
            resultsParser = obj.getResultsParser();
            extensions = ResultsParser.extensions;
            title = "Export Detrended Traces";
            startDirectory = obj.resultsDirectory;
            [filepath, isfilepath] = uiputfilepath(extensions, title, startDirectory);
            if ~isfilepath
                return;
            end

            regionCount = resultsParser.getRegionCount();
            windowSize = obj.getWindowSize();
            windowName = obj.getWindowName();
            for regionIndex = 1:regionCount
                resultsParser.redetrendTrace(windowSize, windowName, regionIndex);
            end
            resultsParser.export(filepath);
        end
    end
    methods (Access = private)
        function updateDisplay(obj, ~, ~)
            traceLines = obj.getTraceLines();
            trendLines = obj.getTrendLines();
            traceScatters = obj.getTraceScatters();
            windowSize = obj.getWindowSize();
            windowName = obj.getWindowName();
            resultsParser = obj.getResultsParser();
            x = resultsParser.getProcessedTrace();
            y = resultsParser.getProcessedTrace2();

            xDetrend = detrendTrace(x, windowSize, windowName);
            yDetrend = detrendTrace(y, windowSize, windowName);

            set(traceLines, {"YData"}, num2cell(xDetrend, 2));
            set(trendLines, {"YData"}, num2cell(x - xDetrend, 2));
            set( ...
                traceScatters, ...
                {"YData"}, num2cell(xDetrend, 2), ...
                {"XData"}, num2cell(yDetrend, 2) ...
                );
            Waterfall.reOffsetLines(traceLines);
            Waterfall.reOffsetLines(traceScatters);
        end
    end

    %% Functions to retrieve GUI elements and state information
    methods (Access = private)
        function gui = getGui(obj)
            gui = obj.gui;
        end
        function traceLines = getTraceLines(obj)
            traceLines = obj.traceLines;
        end
        function trendLines = getTrendLines(obj)
            trendLines = obj.trendLines;
        end
        function traceScatters = getTraceScatters(obj)
            traceScatters = obj.traceScatters;
        end
        function resultsParser = getResultsParser(obj)
            resultsParser = obj.resultsParser;
        end
    end

    %% Helper functions to retrieve GUI elements and state information
    methods (Access = private)
        function ax = getTraceAxis(obj)
            ax = obj.getGui().getTraceAxis();
        end
        function ax = getTrendAxis(obj)
            ax = obj.getGui().getTrendAxis();
        end
        function ax = getWindowAxis(obj)
            ax = obj.axWindow;
        end
        function windowSize = getWindowSize(obj)
            windowSize = obj.getWindowAxis().getWindowSize();
        end
        function windowName = getWindowName(obj)
            windowName = obj.getWindowAxis().getWindowName();
        end
    end
end


function xDetrend = detrendTrace(x, windowSize, windowName)
xDetrend = detrend(x.', 1);
xDetrend = xDetrend - MovingAverage.averageByKeyword2(xDetrend, windowSize, windowName);
xDetrend = xDetrend.';
end
