classdef AxisAdjuster < handle
    properties (Access = private)
        axis;
        xlimBounds;
        ylimBounds;
    end

    methods
        function obj = AxisAdjuster(ax)
            prepareAxis(ax);

            obj.axis = ax;
            obj.xlimBounds = get(ax, "XLim");
            obj.ylimBounds = get(ax, "YLim");
        end
    end

    %% Functions to retrieve GUI elements
    methods (Access = protected)
        function ax = getAxis(obj)
            ax = obj.axis;
        end
        function fig = getFigure(obj)
            ax = obj.getAxis();
            fig = ancestor(ax, "figure");
        end
    end

    %% Functions to retrieve state information
    methods (Access = protected)
        function xlim = getBoundsX(obj)
            xlim = obj.xlimBounds;
        end
        function ylim = getBoundsY(obj)
            ylim = obj.ylimBounds;
        end
        function is = limitInBoundsX(obj, xlim)
            xlimBounds = obj.getBoundsX();
            is = limitInBounds(xlimBounds, xlim);
        end
        function is = limitInBoundsY(obj, ylim)
            ylimBounds = obj.getBoundsY();
            is = limitInBounds(ylimBounds, ylim);
        end

        function xlim = getLimitX(obj)
            ax = obj.getAxis();
            xlim = get(ax, "XLim");
        end
        function ylim = getLimitY(obj)
            ax = obj.getAxis();
            ylim = get(ax, "YLim");
        end
        function x = getMousePointX(obj)
            ax = obj.getAxis();
            x = getAxisPointX(ax);
        end
        function y = getMousePointY(obj)
            ax = obj.getAxis();
            y = getAxisPointY(ax);
        end
    end

    %% Functions to set axis limits
    methods (Access = protected)
        function setLimitX(obj, xlim)
            ax = obj.getAxis();
            set(ax, "Xlim", xlim);
        end
        function setLimitY(obj, ylim)
            ax = obj.getAxis();
            set(ax, "Ylim", ylim);
        end

        function cDataChanged(obj, ~, ~)
            obj.setBoundsToCurrent();
        end
        function setBoundsToCurrent(obj)
            ax = obj.getAxis();
            xlim = get(ax, "XLim");
            ylim = get(ax, "YLim");

            obj.setBoundsX(xlim);
            obj.setBoundsY(ylim);
        end
        function setBoundsX(obj, xlim)
            obj.xlimBounds = xlim;
        end
        function setBoundsY(obj, ylim)
            obj.ylimBounds = ylim;
        end
    end
end



function prepareAxis(ax)
set(ax, ...
    "XLimMode", "manual", ...
    "YLimMode", "manual" ...
    );
end

function is = limitInBounds(lim, limNew)
limStart = lim(1);
limNewStart = limNew(1);
limEnd = lim(2);
limNewEnd = limNew(2);
is = limNewStart >= limStart ...
    && limNewEnd <= limEnd;
end

function point = getAxisPoint(ax)
point = get(ax, 'CurrentPoint');
point = point(1, 1:2);
end
function x = getAxisPointX(ax)
point = getAxisPoint(ax);
x = point(1, 1);
end
function y = getAxisPointY(ax)
point = getAxisPoint(ax);
y = point(1, 2);
end