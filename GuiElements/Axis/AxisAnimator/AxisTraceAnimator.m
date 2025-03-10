classdef AxisTraceAnimator < AxisAnimator
    properties (Access = private)
        trace;
        animatedLine;
    end

    methods
        function obj = AxisTraceAnimator(ax, t, x, varargin)
            obj@AxisAnimator(ax, t, varargin{:});

            line = animatedline(ax, "MaximumNumPoints", Inf);
            set(line, "ContextMenu", obj.getContextMenu());

            obj.trace = x;
            obj.animatedLine = line;
        end
    end

    %% Functions to instantiate abstract methods
    methods
        function x = getTrace(obj, frameIndex)
            x = obj.trace;
            if nargin == 2
                inds = obj.getFrameSlice(frameIndex);
                x = x(inds);
            end
        end
        function clearAnimation(obj)
            animatedLine = obj.getAnimatedLine();
            animatedLine.clearpoints();
        end
        function updateAnimation(obj, frameIndex)
            animatedLine = obj.getAnimatedLine();
            t = obj.getTime(frameIndex);
            x = obj.getTrace(frameIndex);
            animatedLine.addpoints(t, x);
        end
    end

    %% Functions to retrieve GUI elements
    methods
        function line = getAnimatedLine(obj)
            line = obj.animatedLine;
        end
    end
end
