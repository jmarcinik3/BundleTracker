classdef RegionMoverGui < RegionAdjusterGui
    properties (Access = private, Constant)
        filepaths = "img/" + [
            ["arrow-up-left.png", "arrow-up.png", "arrow-up-right.png"]; ...
            ["arrow-left.png", "trash.png", "arrow-right.png"]; ...
            ["arrow-down-left.png", "arrow-down.png", "arrow-down-right.png"]; ...
            ];
        tooltips = [
            ["Move Up-Left", "Move Up (↑)", "Move Up-Right"];
            ["Move Left (←)", "Delete Region", "Move Right (→)"];
            ["Move Down-Left", "Move Down (↓)", "Move Down-Right"];
            ];
    end

    methods
        function obj = RegionMoverGui(parent)
            filepaths = RegionMoverGui.filepaths;
            tooltips = RegionMoverGui.tooltips;
            obj@RegionAdjusterGui(parent, filepaths, "Tooltips", tooltips);
        end
    end
end
