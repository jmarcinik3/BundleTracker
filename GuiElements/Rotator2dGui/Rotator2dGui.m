classdef Rotator2dGui < handle
    properties (Constant, Access = ?Rotator2dLinker)
        activeColor = [0, 1, 0];
        inactiveColor = [1, 0, 0];
        crossLineColor = "red";
        crossLineWidth = 1.5;
    end

    properties (Access = private)
        gridLayout;
        lineX;
        lineY;
        heatmapC;
        roiImage;
        binCount = 0;
    end

    methods
        function obj = Rotator2dGui(fig)
            gl = uigridlayout(fig, [2, 2]);
            axRoi = generateEmptyAxis(gl);
            axHeatmap = uiaxes(gl);
            axTraceX = uiaxes(gl);
            axTraceY = uiaxes(gl);

            hold(axRoi, "on");
            obj.roiImage = imshow([], "Parent", axRoi);
            hold(axRoi, "off");

            obj.lineX = plot(axTraceX, 0, 0, 'k');
            obj.lineY = plot(axTraceY, 0, 0, 'k');
            obj.heatmapC = imagesc(axHeatmap, [], [], 1);
            xline( ...
                axHeatmap, ...
                0, ...
                "Color", Rotator2dGui.crossLineColor, ...
                "LineWidth", Rotator2dGui.crossLineWidth ...
                );
            yline( ...
                axHeatmap, ...
                0, ...
                "Color", Rotator2dGui.crossLineColor, ...
                "LineWidth", Rotator2dGui.crossLineWidth ...
                );

            obj.gridLayout = gl;
            layoutElements(obj);
        end
    end

    %% Functions to retrieve GUI elements and state information
    methods (Access = ?Rotator2dLinker)
        function fig = getFigure(obj)
            gl = obj.getGridLayout();
            fig = ancestor(gl, "figure");
        end
        function gl = getGridLayout(obj)
            gl = obj.gridLayout;
        end

        function iIm = getRoiImage(obj)
            iIm = obj.roiImage;
        end
        function line = getLineX(obj)
            line = obj.lineX;
        end
        function line = getLineY(obj)
            line = obj.lineY;
        end
        function heatmap = getHeatmap(obj)
            heatmap = obj.heatmapC;
        end
        function ax = getRoiAxis(obj)
            iIm = obj.getRoiImage();
            ax = get(iIm, "Parent");
        end
        function ax = getTraceAxisX(obj)
            lineX = obj.getLineX();
            ax = get(lineX, "Parent");
        end
        function ax = getTraceAxisY(obj)
            lineY = obj.getLineY();
            ax = get(lineY, "Parent");
        end
        function ax = getHeatmapAxis(obj)
            heatmap = obj.getHeatmap();
            ax = get(heatmap, "Parent");
        end
    end
end


function layoutElements(gui)
gl = gui.getGridLayout();
axRoi = gui.getRoiAxis();
axTraceX = gui.getTraceAxisX();
axTraceY = gui.getTraceAxisY();
axHeatmap = gui.getHeatmapAxis();

axRoi.Layout.Row = 1;
axRoi.Layout.Column = 1;

axHeatmap.Layout.Row = 2;
axHeatmap.Layout.Column = 1;
pbaspect(axHeatmap, [1, 1, 1]);
xlabel(axHeatmap, "Position [x]");
ylabel(axHeatmap, "Position [y]");

axTraceX.Layout.Row = 1;
axTraceX.Layout.Column = 2;
xlabel(axTraceX, "Time");
ylabel(axTraceX, "Position [x]");

axTraceY.Layout.Row = 2;
axTraceY.Layout.Column = 2;
xlabel(axTraceY, "Time");
ylabel(axTraceY, "Position [y]");

linkaxes([axTraceX, axTraceY], 'x');
linkaxes([axTraceY, axHeatmap], 'y');

set(gl, "ColumnWidth", {'1x', '2x'});
end
