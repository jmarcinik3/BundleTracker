classdef LineAccenter < handle
    properties (Constant, Access = private)
        defaultWidth = 0.5;
        accentWidth = 2;
    end

    properties (Access = private)
        defaultColor = [1, 0, 0, 0.1667];
        accentColor = [1, 0, 0, 1];
    end

    properties (Access = private)
        axis; % axis on which waterfall is plotted
        lineObjs; % array of Line objects plotted on axis
    end

    methods
        function obj = LineAccenter(lineObjs)
            ax = get(lineObjs(1), "Parent");
            set(lineObjs, "Color", obj.defaultColor);

            obj.axis = ax;
            obj.lineObjs = lineObjs;
        end
    end

    %% Functions to retrieve GUI elements
    methods (Access = protected)
        function ax = getAxis(obj)
            ax = obj.axis;
        end
        function lineObjs = getLineObjects(obj, index)
            if nargin == 1
                lineObjs = obj.lineObjs;
            else
                lineObjs = obj.lineObjs(index);
            end
        end
    end

    %% Functions to set state information
    methods (Access = protected)
        function setColor(obj, color)
            obj.accentColor(1:3) = color;
            obj.defaultColor(1:3) = color;
        end
        function setDefaultAlpha(obj, alpha)
            obj.defaultColor(4) = alpha;
        end
    end

    %% Functions to update state of GUI
    methods (Access = protected)
        function accentLine(obj, accentLines)
            LineAccenter.accentLineColor(obj, accentLines);
            LineAccenter.accentLineWidth(obj, accentLines);
        end
        function accentLineColor(obj, accentLines)
            lineObjs = obj.getLineObjects();
            accentLineColor( ...
                accentLines, lineObjs, ...
                "DefaultColor", obj.defaultColor, ...
                "AccentColor", obj.accentColor ...
                );
        end
        function accentLineWidth(obj, accentLines)
            lineObjs = obj.getLineObjects();
            accentLineWidth( ...
                accentLines, lineObjs, ...
                "DefaultLineWidth", LineAccenter.defaultWidth, ...
                "AccentLineWidth", LineAccenter.accentWidth ...
                );
        end
        function accentNone(obj)
            lineObjs = obj.getLineObjects();
            set(lineObjs, "Color", obj.defaultColor);
            set(lineObjs, "LineWidth", WaterfallAxes.defaultWidth);
        end
    end
end



function accentLineColor(accentLineObjs, unaccentLineObjs, varargin)
p = inputParser;
addOptional(p, "DefaultColor", "black");
addOptional(p, "AccentColor", "red");
parse(p, varargin{:});
defaultColor = p.Results.DefaultColor;
accentColor = p.Results.AccentColor;

set(unaccentLineObjs, "Color", defaultColor);
existsLine = numel(accentLineObjs) >= 1;
if existsLine
    set(accentLineObjs, "Color", accentColor);
end
end

function accentLineWidth(accentLineObjs, unaccentLineObjs, varargin)
p = inputParser;
addOptional(p, "DefaultLineWidth", 1);
addOptional(p, "AccentLineWidth", 0.5);
parse(p, varargin{:});
defaultWidth = p.Results.DefaultLineWidth;
accentWidth = p.Results.AccentLineWidth;

set(unaccentLineObjs, "LineWidth", defaultWidth);
existsLine = numel(accentLineObjs) >= 1;
if existsLine
    set(accentLineObjs, "LineWidth", accentWidth);
end
end
