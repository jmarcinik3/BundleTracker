classdef RegionExpanderGui < RegionAdjusterGui
    properties (Access = private, Constant)
        filepaths = "img/" + [
            ["expand-up-left.png", "expand-up.png", "expand-up-right.png"]; ...
            ["expand-left.png", "arrows-out.png", "expand-right.png"]; ...
            ["expand-down-left.png", "expand-down.png", "expand-down-right.png"]; ...
            ];
        tooltips = [
            ["Expand Up-Left", "Expand Up (Ctrl+Shift++↑)", "Expand Up-Right"];
            ["Expand Left (Ctrl+Shift+←)", "Expand In", "Expand Right (Ctrl+Shift+→)"];
            ["Expand Down-Left", "Expand Down (Ctrl+Shift+↓)", "Expand Down-Right"];
            ];
    end

    methods
        function obj = RegionExpanderGui(parent)
            filepaths = RegionExpanderGui.filepaths;
            tooltips = RegionExpanderGui.tooltips;
            obj@RegionAdjusterGui(parent, filepaths, "Tooltips", tooltips);
        end
    end
end
