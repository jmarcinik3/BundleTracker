classdef DetrenderGui < handle
    properties (Access = private)
        gridLayout;
        axTrace;
        axTrend;
        axWindow;
        axTrace2d;
    end

    methods
        function obj = DetrenderGui(fig)
            gl = uigridlayout(fig, [3, 2]);
            axTrace = uiaxes(gl, "Toolbar", []);
            axTrend = uiaxes(gl, "Toolbar", []);
            axWindow = AxisWindow.generateAxis(gl);
            axTrace2d = uiaxes(gl, "Toolbar", []);

            obj.gridLayout = gl;
            obj.axTrace = axTrace;
            obj.axTrend = axTrend;
            obj.axWindow = axWindow;
            obj.axTrace2d = axTrace2d;
            layoutElements(obj);
        end
    end

    %% Functions to retrieve GUI elements and state information
    methods (Access = ?DetrenderLinker)
        function fig = getFigure(obj)
            gl = obj.getGridLayout();
            fig = ancestor(gl, "figure");
        end
        function gl = getGridLayout(obj)
            gl = obj.gridLayout;
        end

        function ax = getTraceAxis(obj)
            ax = obj.axTrace;
        end
        function ax = getTrendAxis(obj)
            ax = obj.axTrend;
        end
        function ax = getWindowAxis(obj)
            ax = obj.axWindow;
        end
        function s = getTraceAxis2d(obj)
            s = obj.axTrace2d;
        end
    end
end


function layoutElements(gui)
gl = gui.getGridLayout();
axWindow = gui.getWindowAxis();
axTrace = gui.getTraceAxis();
axTrend = gui.getTrendAxis();
axTrace2d = gui.getTraceAxis2d();

axWindow.Layout.Row = 1;
axWindow.Layout.Column = [1, 2];

axTrace.Layout.Row = 2;
axTrace.Layout.Column = 1;
xlabel(axTrace, " ");
ylabel(axTrace, "Detrended [x]");
set(axTrace, "XColor", "none");

axTrend.Layout.Row = 3;
axTrend.Layout.Column = 1;
xlabel(axTrend, "Time");
ylabel(axTrend, "Trend [x]");
set(axTrend, "XAxisLocation", "origin");

axTrace2d.Layout.Row = 2;
axTrace2d.Layout.Column = 2;
axTrace2d.YAxis.Visible = "off";
xlabel(axTrace2d, "Detrended [y]");

set(gl, ...
    "RowHeight", {'1x', '3x', '1x'}, ...
    "RowSpacing", 0, ...
    "ColumnWidth", {'2x', '1x'}, ...
    "ColumnSpacing", 0 ...
    );
end
