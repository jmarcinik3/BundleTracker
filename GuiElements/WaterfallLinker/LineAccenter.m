classdef LineAccenter < handle
    properties (Access = private)
        defaultWidth;
        accentWidth;
        defaultColor;
        accentColor;
        lineObjs;
    end

    methods
        function obj = LineAccenter(lineObjs, varargin)
            p = inputParser;
            addOptional(p, "DefaultWidth", 0.5);
            addOptional(p, "AccentWidth", 2);
            addOptional(p, "DefaultColor", [1, 0, 0, 0.1667]);
            addOptional(p, "AccentColor", [1, 0, 0, 1]);
            parse(p, varargin{:});
            obj.defaultWidth = p.Results.DefaultWidth;
            obj.accentWidth = p.Results.AccentWidth;
            obj.defaultColor = p.Results.DefaultColor;
            obj.accentColor = p.Results.AccentColor;

            set(lineObjs, "Color", obj.defaultColor);
            obj.lineObjs = lineObjs;
        end
    end

    %% Functions to retreive GUI elements
    methods (Access = private)
        function lineObjs = getLineObjects(obj)
            lineObjs = obj.lineObjs;
        end
    end

    %% Functions to set state information
    methods
        function setColor(obj, color)
            obj.accentColor(1:3) = color;
            obj.defaultColor(1:3) = color;
        end
        function setDefaultAlpha(obj, alpha)
            obj.defaultColor(4) = alpha;
        end
    end

    %% Functions to update state of GUI
    methods
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
                "DefaultLineWidth", obj.defaultWidth, ...
                "AccentLineWidth", obj.accentWidth ...
                );
        end
        function accentNone(obj)
            lineObjs = obj.getLineObjects();
            set(lineObjs, "Color", obj.defaultColor);
            set(lineObjs, "LineWidth", obj.defaultWidth);
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
if numel(accentLineObjs) >= 1
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
if numel(accentLineObjs) >= 1
    set(accentLineObjs, "LineWidth", accentWidth);
end
end
