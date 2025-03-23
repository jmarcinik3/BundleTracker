classdef AxisPanner < AxisAdjuster
    properties (Access = private, Constant)
        panMouseButton = "alt";  % ctrl-click or right-click
    end

    properties (Access = private)
        panningSeedPoint;
    end

    methods
        function obj = AxisPanner(ax)
            obj@AxisAdjuster(ax);
            fig = ancestor(ax, "figure");
            set(fig, ...
                "Units", "pixels", ...
                "WindowButtonDownFcn", @obj.windowButtonDownFcn, ...
                "WindowButtonUpFcn", @obj.windowButtonUpFcn ...
                );
        end
    end

    %% Functions to generate objects
    methods (Access = private)
        function xlimNew = generatePannedX(obj)
            seedPointX = obj.getPanningSeedX();
            mousePointX = obj.getMousePointX();
            xlim = obj.getLimitX();
            xlimNew = panLimit(mousePointX, seedPointX, xlim);
        end
        function ylimNew = generatePannedY(obj)
            seedPointY = obj.getPanningSeedY();
            mousePointY = obj.getMousePointY();
            ylim = obj.getLimitY();
            ylimNew = panLimit(mousePointY, seedPointY, ylim);
        end
    end

    %% Functions to set state information and state of GUI
    methods (Access = private)
        function point = getPanningSeed(obj)
            point = obj.panningSeedPoint;
        end
        function x = getPanningSeedX(obj)
            point = getPanningSeed(obj);
            x = point(1);
        end
        function y = getPanningSeedY(obj)
            point = getPanningSeed(obj);
            y = point(2);
        end
    end

    %% Functions to update state of GUI
    methods (Access = private)
        function windowButtonDownFcn(obj, ~, event)
            selectionType = event.Source.SelectionType;
            if selectionType == obj.panMouseButton
                obj.startPan();
            end
        end
        function windowButtonUpFcn(obj, ~, ~)
            obj.stopPan();
        end

        function startPan(obj)
            obj.prepareSeedForPanning();
            obj.prepareFigureForPanning();
        end
        function prepareSeedForPanning(obj)
            ax = obj.getAxis();
            seedPoint = AxisPoint.getXy(ax);
            obj.panningSeedPoint = seedPoint;
        end
        function prepareFigureForPanning(obj)
            fig = obj.getFigure();
            set(fig, "WindowButtonMotionFcn", @obj.doPan);
            setptr(fig, "hand");
        end
        function stopFigureForPanning(obj)
            fig = obj.getFigure();
            set(fig, "WindowButtonMotionFcn", []);
            setptr(fig, "arrow");
        end

        function doPan(obj, ~, ~)
            obj.doPanX();
            obj.doPanY();
        end
        function doPanX(obj)
            xlimNew = obj.generatePannedX();
            if obj.limitInBoundsX(xlimNew)
                obj.setLimitX(xlimNew);
            end
        end
        function doPanY(obj)
            ylimNew = obj.generatePannedY();
            if obj.limitInBoundsY(ylimNew)
                obj.setLimitY(ylimNew);
            end
        end

        function stopPan(obj)
            obj.stopFigureForPanning();
        end
    end
end



function limNew = panLimit(mouseLocation, seedLocation, lim)
limDelta = mouseLocation - seedLocation;
limNew = lim - limDelta;
end
