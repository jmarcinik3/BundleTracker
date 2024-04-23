classdef AlertThrower < handle
    methods (Abstract, Access = protected)
        getFigure(obj);
    end

    methods (Access = protected)
        function throwAlertMessage(obj, message, title)
            fig = obj.getFigure();
            uialert(fig, message, title);
        end
    end
end

