classdef PanZoomer < handle
    properties (Access = private, Constant)
        panMouseButton = "alt";  % ctrl-click or right-click
        magnificationFactor = 2^(1/12);
    end

    properties (Access = private)
        axis;

        xlimOriginal;
        ylimOriginal;
        panningSeedPoint;
    end

    methods
        function obj = PanZoomer(ax)
            fig = ancestor(ax, "figure");
            obj.prepareFigure(fig);
            prepareAxis(ax);

            obj.axis = ax;
            obj.xlimOriginal = get(ax, "XLim");
            obj.ylimOriginal = get(ax, "YLim");
        end
    end

    %% Functions to retrieve GUI elements
    methods (Access = private)
        function ax = getAxis(obj)
            ax = obj.axis;
        end
        function fig = getFigure(obj)
            ax = obj.getAxis();
            fig = ancestor(ax, "figure");
        end
    end

    methods (Access = private)
        function prepareFigure(obj, fig)
            set(fig, ...
                "Units", "pixels", ...
                "WindowScrollWheelFcn", @obj.windowScrollWheelFcn, ...
                "WindowButtonDownFcn", @obj.windowButtonDownFcn, ...
                "WindowButtonUpFcn", @obj.windowButtonUpFcn ...
                );
        end

        function windowScrollWheelFcn(obj, ~, event)
            scrollDirection = event.VerticalScrollCount;
            scrollAmount = event.VerticalScrollAmount;
            factor = obj.magnificationFactor^scrollAmount;

            if scrollDirection == -1
                obj.increaseMagnification(factor);
            elseif scrollDirection == 1
                obj.decreaseMagnification(factor);
            end
        end
        function increaseMagnification(obj, factor)
            xlimNew = obj.calculateMagnifiedLimX(factor);
            ylimNew = obj.calculateMagnifiedLimY(factor);

            if obj.limIsValidX(xlimNew)
                obj.setXLim(xlimNew);
            end
            if obj.limIsValidY(ylimNew)
                obj.setYLim(ylimNew);
            end
        end
        function decreaseMagnification(obj, factor)
            increaseFactor = 1 / factor;
            obj.increaseMagnification(increaseFactor);
        end

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
            seedPoint = getAxisPoint(ax);
            obj.setPanningSeed(seedPoint);
        end
        function prepareFigureForPanning(obj)
            fig = obj.getFigure();
            set(fig, "WindowButtonMotionFcn", @obj.doPan);
            setptr(fig, "hand");
        end
        function stopFigureForPanning(obj)
            fig = obj.getFigure();
            stopFigureForPanning(fig);
        end

        function doPan(obj, ~, ~)
            obj.doPanX();
            obj.doPanY();
        end
        function doPanX(obj)
            xlimNew = obj.calculatePannedLimX();
            if obj.limIsValidX(xlimNew)
                obj.setXLim(xlimNew);
            end
        end
        function doPanY(obj)
            ylimNew = obj.calculatePannedLimY();
            if obj.limIsValidY(ylimNew)
                obj.setYLim(ylimNew);
            end
        end

        function stopPan(obj)
            obj.stopFigureForPanning();
        end
    end

    methods (Access = private)
        function setPanningSeed(obj, point)
            obj.panningSeedPoint = point;
        end
        function setXLim(obj, xlim)
            ax = obj.getAxis();
            set(ax, "Xlim", xlim);
        end
        function setYLim(obj, ylim)
            ax = obj.getAxis();
            set(ax, "Ylim", ylim);
        end

        function point = getPanningSeed(obj)
            point = obj.panningSeedPoint;
        end

        function xlim = getOriginalXLim(obj)
            xlim = obj.xlimOriginal;
        end
        function ylim = getOriginalYLim(obj)
            ylim = obj.ylimOriginal;
        end
        function is = limIsValidX(obj, xlim)
            xlimOriginal = obj.getOriginalXLim();
            is = limIsValid(xlimOriginal, xlim);
        end
        function is = limIsValidY(obj, ylim)
            ylimOriginal = obj.getOriginalYLim();
            is = limIsValid(ylimOriginal, ylim);
        end

        function xlimNew = calculateMagnifiedLimX(obj, factor)
            ax = obj.getAxis();
            xlimOriginal = obj.getOriginalXLim();
            mousePointX = getAxisPointX(ax);
            xlim = get(ax, "XLim");

            xlimNew = calculateMagnifiedLim(factor, mousePointX, xlim);
            xlimNew = calculatePaddedLim(xlimOriginal, xlimNew);
        end
        function ylimNew = calculateMagnifiedLimY(obj, factor)
            ax = obj.getAxis();
            ylimOriginal = obj.getOriginalYLim();
            mousePointY = getAxisPointY(ax);
            ylim = get(ax, "YLim");

            ylimNew = calculateMagnifiedLim(factor, mousePointY, ylim);
            ylimNew = calculatePaddedLim(ylimOriginal, ylimNew);
        end
        function xlimNew = calculatePannedLimX(obj)
            ax = obj.getAxis();
            seedPoint = obj.getPanningSeed();
            xlimNew = calculatePannedLimX(ax, seedPoint);
        end
        function ylimNew = calculatePannedLimY(obj)
            ax = obj.getAxis();
            seedPoint = obj.getPanningSeed();
            ylimNew = calculatePannedLimY(ax, seedPoint);
        end
    end

    methods
        function fitOriginalLimsToAxis(obj)
            ax = obj.getAxis();
            xlim = get(ax, "XLim");
            ylim = get(ax, "YLim");

            obj.setOriginalXLim(xlim);
            obj.setOriginalYLim(ylim);
        end
        function setOriginalXLim(obj, xlim)
            obj.xlimOriginal = xlim;
        end
        function setOriginalYLim(obj, ylim)
            obj.ylimOriginal = ylim;
        end
    end
end



function prepareAxis(ax)
set(ax, ...
    "XLimMode", "manual", ...
    "YLimMode", "manual" ...
    );
end

function stopFigureForPanning(fig)
set(fig, "WindowButtonMotionFcn", []);
setptr(fig, "arrow");
end

function is = limIsValid(lim, limNew)
limStart = lim(1);
limNewStart = limNew(1);
limEnd = lim(2);
limNewEnd = limNew(2);

startIsValid = limStartIsValid(limStart, limNewStart);
endIsValid = limEndIsValid(limEnd, limNewEnd);
is = startIsValid && endIsValid;
end
function is = limStartIsValid(limStart, limNewStart)
is = limNewStart >= limStart;
end
function is = limEndIsValid(limEnd, limNewEnd)
is = limNewEnd <= limEnd;
end

function point = getAxisPoint(ax)
point = get(ax, 'CurrentPoint');
point = point(1, :);
end
function x = getAxisPointX(ax)
point = getAxisPoint(ax);
x = point(1, 1);
end
function y = getAxisPointY(ax)
point = getAxisPoint(ax);
y = point(1, 2);
end

function limNew = calculateMagnifiedLim(factor, mouseLocation, lim)
limNew = (lim - mouseLocation) / factor + mouseLocation;
end
% shifts lim to be inside limPad, useful when zooming out
function limNew = calculatePaddedLim(limPad, lim)
limStart = lim(1);
limEnd = lim(2);

limPadStart = limPad(1);
limPadEnd = limPad(2);
limPadRange = diff(limPad);

startIsValid = limStartIsValid(limPadStart, limStart);
endIsValid = limEndIsValid(limPadEnd, limEnd);

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

function xlimNew = calculatePannedLimX(ax, seedPoint)
mousePointX = getAxisPointX(ax);
seedPointX = seedPoint(1);
xlim = get(ax, "XLim");
xlimNew = getPannedLim(mousePointX, seedPointX, xlim);
end
function ylimNew = calculatePannedLimY(ax, seedPoint)
mousePointY = getAxisPointY(ax);
seedPointY = seedPoint(2);
ylim = get(ax, "YLim");
ylimNew = getPannedLim(mousePointY, seedPointY, ylim);
end
function limNew = getPannedLim(mouseLocation, seedLocation, lim)
seedRelative = getRelativeLocation(seedLocation, lim);
mouseRelative = getRelativeLocation(mouseLocation, lim);
limDelta = mouseRelative - seedRelative;
limNew = getShiftedLim(limDelta, lim);
end
function limNew = getShiftedLim(delta, lim)
limStart = lim(1);
limRange = diff(lim);

limNewStart = limStart - delta * limRange;
limNewEnd = limNewStart + limRange;
limNew = [limNewStart, limNewEnd];
limNew = round(limNew);
end
function relativeLoc = getRelativeLocation(loc, lim)
limStart = lim(1);
limEnd = lim(2);
limRange = limEnd - limStart;
relativeLoc = (loc - limStart) / limRange;
end
