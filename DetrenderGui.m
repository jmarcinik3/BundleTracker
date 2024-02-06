classdef DetrenderGui < handle
    properties (Access = private)
        results; %#ok<*PROP>
        axis;
        windowSize;
        windowShape;

        traceAxis;
        comparisonAxis;
        fourierAxis;

        traceLine;
        correctedTraceLine;
        movingAverageLine;
        linearRegressionLine;

        fourierLine;
        fourierDifferenceLine;

        maxCrossCorrelationScatter;
        slopeScatter;
        maxFourierDifferenceScatter;
        comparisonVerticalLine;

        memory = struct( ...
            "WindowSize", [], ...
            "Slope", [], ...
            "MaxFourierDifference", [], ...
            "MaxCrossCorrelation", [] ...
            );

        xFourier;
        isFirstPlot = true;
    end

    methods
        function obj = DetrenderGui(resultsFilepath)
            load(resultsFilepath, "results");
            x = results.xProcessed;
            obj.results = results;

            fig = uifigure;
            fig.Name = "Detrender GUI";
            gridLayout = uigridlayout(fig, [3 2]);

            maximumWindowSize = width(x);
            slider = generateSlider(gridLayout, maximumWindowSize);
            slider.ValueChangingFcn = @(src, ev) obj.sliderChanging(src, ev);

            dropdown = uidropdown(gridLayout);
            dropdown.ValueChangedFcn = @(src, ev) obj.dropdownChanged(src, ev);
            dropdown.Items = MovingAverage.keywords;
            dropdown.Value = MovingAverage.hann;

            obj.windowSize = slider.Value;
            obj.windowShape = dropdown.Value;
            traceAxis = generateTraceAxis(gridLayout);
            comparisonAxis = generateComparisonAxis(gridLayout);
            fourierAxis = generateFourierAxis(gridLayout);

            obj.traceAxis = traceAxis;
            obj.comparisonAxis = comparisonAxis;
            obj.fourierAxis = fourierAxis;

            traceAxis.Layout.Row = [1 2];
            traceAxis.Layout.Column = 1;
            comparisonAxis.Layout.Row = 2;
            comparisonAxis.Layout.Column = 2;
            fourierAxis.Layout.Row = 1;
            fourierAxis.Layout.Column = 2;

            slider.Layout.Row = 3;
            slider.Layout.Column = 1;
            dropdown.Layout.Row = 3;
            dropdown.Layout.Column = 2;
            gridLayout.RowHeight = {'4x', '4x', '1x'};
            gridLayout.ColumnWidth = {'2x', '1x'};

            obj.updateDisplay();
        end
    end

    methods (Access = private)
        function updateDisplay(obj)
            results = obj.results;
            x = results.xProcessed;
            t = results.t;
            windowSize = obj.windowSize;

            ma = MovingAverage.averageByKeyword(x, windowSize, obj.windowShape);
            xCorrected = x - ma;
            pfit = polyfit(t, xCorrected, 1);
            lm = polyval(pfit, t);
            xcfa = abs(fftshift(fft(xCorrected)));

            if obj.isFirstPlot
                traceAxis = obj.traceAxis;
                comparisonAxis = obj.comparisonAxis;
                fourierAxis = obj.fourierAxis;

                fps = results.Fps;
                xsize = length(x);
                xff = (-xsize/2:xsize/2-1) * (fps / xsize);
                xfa = abs(fftshift(fft(x)));

                hold(traceAxis, "on");
                plot(traceAxis, t, x, 'k');
                obj.correctedTraceLine = plot(traceAxis, t, xCorrected, 'b');
                obj.movingAverageLine = plot(traceAxis, t, ma, 'r');
                obj.linearRegressionLine = plot(traceAxis, t, lm, 'g');
                hold(traceAxis, "off");
                legend(traceAxis, ...
                    ["Original", "Corrected", "Moving Average", "Linear Regression"] ...
                    );
                traceAxis.XLim = [t(1), t(end)];

                hold(comparisonAxis, "on");
                obj.maxFourierDifferenceScatter = ...
                    scatter(comparisonAxis, 0, 0, 16, 'm', "filled");
                obj.maxCrossCorrelationScatter = ...
                    scatter(comparisonAxis, 0, 0, 16, 'r', "filled");
                obj.slopeScatter = ...
                    scatter(comparisonAxis, 0, 0, 16, 'g', "filled");
                obj.comparisonVerticalLine = xline(comparisonAxis, windowSize, 'k--');
                hold(comparisonAxis, "off");
                legend(comparisonAxis, ...
                    ["Max Fourier Difference", "Max Cross-Correlation", "Slope"]);
                comparisonAxis.YLim = [0, 1];

                obj.xFourier = xfa;
                hold(fourierAxis, "on");
                plot(fourierAxis, xff, xfa, 'k');
                obj.fourierLine = plot(fourierAxis, xff, xcfa, 'b');
                obj.fourierDifferenceLine = plot(fourierAxis, xff, abs(xfa - xcfa), 'r');
                hold(fourierAxis, "off");
                legend(fourierAxis, ["Original", "Corrected", "Difference"]);
                fourierAxis.XLim = [min(xff), max(xff)];

                obj.isFirstPlot = false;
            else
                xfaDiff = abs(obj.xFourier - xcfa);

                obj.linearRegressionLine.YData = lm;
                obj.correctedTraceLine.YData = xCorrected;
                obj.movingAverageLine.YData = ma;
                obj.fourierLine.YData = xcfa;
                obj.fourierDifferenceLine.YData = xfaDiff;
            end

            if ~ismember(windowSize, obj.memory.WindowSize)
                [xcf, ~] = crosscorr(x, xCorrected);
                xfaDiff = abs(obj.xFourier - xcfa);

                obj.memory.WindowSize(end+1) = windowSize;
                obj.memory.Slope(end+1) = abs(pfit(1));
                obj.memory.MaxFourierDifference(end+1) = max(xfaDiff);
                obj.memory.MaxCrossCorrelation(end+1) = max(xcf);

                obj.maxFourierDifferenceScatter.XData = obj.memory.WindowSize;
                obj.maxCrossCorrelationScatter.XData = obj.memory.WindowSize;
                obj.slopeScatter.XData = obj.memory.WindowSize;

                slopes = obj.memory.Slope;
                fourierDiffs = obj.memory.MaxFourierDifference;
                obj.maxFourierDifferenceScatter.YData = fourierDiffs / max(fourierDiffs);
                obj.maxCrossCorrelationScatter.YData = obj.memory.MaxCrossCorrelation;
                obj.slopeScatter.YData = slopes / max(slopes);
            end
            obj.comparisonVerticalLine.Value = windowSize;
        end

        function dropdownChanged(obj, ~, ev)
            obj.memory = struct( ...
                "WindowSize", [], ...
                "Slope", [], ...
                "MaxFourierDifference", [], ...
                "MaxCrossCorrelation", [] ...
                );

            obj.windowShape = ev.Value;
            obj.updateDisplay();
        end

        function sliderChanging(obj, src, ev)
            newWindowSize = round(ev.Value);
            if newWindowSize ~= obj.windowSize
                obj.windowSize = newWindowSize;
                src.Tooltip = sprintf("Window Size: %d", newWindowSize);
                obj.updateDisplay();
            end
        end
    end
end

function ax = generateTraceAxis(gl)
ax = uiaxes(gl);
title(ax, "Traces");
xlabel(ax, "Time [s]");
ylabel(ax, "Position [nm]");
end

function ax = generateComparisonAxis(gl)
ax = uiaxes(gl);
title(ax, "Comparison");
xlabel(ax, "Window Size [smp]");
ylabel(ax, "Relative Quantity");
end

function ax = generateFourierAxis(gl)
ax = uiaxes(gl);
title(ax, "Fourier Transform");
xlabel(ax, "Frequency [Hz]");
ylabel(ax, "Amplitude [nm]");
end

function sl = generateSlider(gl, maximumWindowSize)
minimumLimit = 3;
sl = uislider(gl);
sl.Limits = [minimumLimit, maximumWindowSize];
sl.Value = minimumLimit;

minorTickInterval = maximumWindowSize / 100;
minorTicks = round(0:minorTickInterval:maximumWindowSize);
minorTicks(1) = minimumLimit;
majorTicks = minorTicks(1:10:end);
sl.MinorTicks = minorTicks;
sl.MajorTicks = majorTicks;
end
