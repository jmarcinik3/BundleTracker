classdef AxisZoomer < AxisAdjuster
    properties (Access = private, Constant)
        magnificationFactor = 2^(1/12);
    end

    methods
        function obj = AxisZoomer(ax)
            obj@AxisAdjuster(ax);

            fig = ancestor(ax, "figure");
            set(fig, "WindowScrollWheelFcn", @obj.windowScrollWheelFcn);
        end
    end

    methods (Access = private)
        function windowScrollWheelFcn(obj, ~, event)
            ax = obj.getAxis();
            if ~AxisPoint.mouseIsOver(ax)
                return;
            end

            scrollDirection = event.VerticalScrollCount;
            scrollAmount = event.VerticalScrollAmount;
            factor = obj.magnificationFactor^scrollAmount;

            if scrollDirection == -1
                obj.zoomIn(factor);
            elseif scrollDirection == 1
                obj.zoomOut(factor);
            end
        end

        function zoomIn(obj, factor)
            obj.zoomInX(factor);
            obj.zoomInY(factor);
        end
        function zoomInX(obj, factor)
            xlimNew = obj.generateZoomedX(factor);
            if obj.limitInBoundsX(xlimNew)
                obj.setLimitX(xlimNew);
            end
        end
        function zoomInY(obj, factor)
            ylimNew = obj.generateZoomedY(factor);
            if obj.limitInBoundsY(ylimNew)
                obj.setLimitY(ylimNew);
            end
        end

        function zoomOut(obj, factor)
            increaseFactor = 1 / factor;
            obj.zoomIn(increaseFactor);
        end
    end

    methods (Access = private)
        function xlimNew = generateZoomedX(obj, factor)
            xBounds = obj.getBoundsX();
            mousePointX = obj.getMousePointX();
            xlim = obj.getLimitX();

            xlimNew = magnifyLimit(factor, mousePointX, xlim);
            xlimNew = padLimit(xBounds, xlimNew);
        end
        function ylimNew = generateZoomedY(obj, factor)
            yBounds = obj.getBoundsY();
            mousePointY = obj.getMousePointY();
            ylim = obj.getLimitY();

            ylimNew = magnifyLimit(factor, mousePointY, ylim);
            ylimNew = padLimit(yBounds, ylimNew);
        end
    end
end



function limNew = magnifyLimit(factor, mouseLocation, lim)
limNew = (lim - mouseLocation) / factor + mouseLocation;
end

% shifts lim to be inside limPad, useful when zooming out
function limNew = padLimit(limPad, lim)
limStart = lim(1);
limEnd = lim(2);

limPadStart = limPad(1);
limPadEnd = limPad(2);
limPadRange = diff(limPad);

startIsValid = limStart >= limPadStart;
endIsValid = limEnd <= limPadEnd;

if startIsValid && endIsValid % lim is valid
    limNewStart = limStart;
    limNewEnd = limEnd;
elseif ~startIsValid && ~endIsValid % lim is longer than limPad
    limNewStart = limPadStart;
    limNewEnd = limPadEnd;
elseif ~startIsValid && endIsValid % limStart is before limPadStart
    limNewStart = limPadStart;
    limNewEnd = limNewStart + limPadRange;
elseif startIsValid && ~endIsValid % limEnd is after limPadEnd
    limNewEnd = limPadEnd;
    limNewStart = limNewEnd - limPadRange;
end
limNew = [limNewStart, limNewEnd];
end
