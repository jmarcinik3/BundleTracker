classdef RegionCompressorGui < RegionAdjusterGui
    properties (Access = private, Constant)
        filepaths = "img/" + [
            ["compress-down-right.png", "compress-down.png", "compress-down-left.png"];
            ["compress-right.png", "arrows-in.png", "compress-left.png"];
            ["compress-up-right.png", "compress-up.png", "compress-up-left.png"];
        ];
        tooltips = [
            ["Compress Down-Right", "Compress Down (Ctrl+↓)", "Compress Down-Left"];
            ["Compress Right (Ctrl+→)", "Compress In", "Compress Left (Ctrl+←)"];
            ["Compress Up-Right", "Compress Up (Ctrl+↑)", "Compress Up-Left"];
            ];
    end

    methods
        function obj = RegionCompressorGui(parent)
            filepaths = RegionCompressorGui.filepaths;
            tooltips = RegionCompressorGui.tooltips;
            obj@RegionAdjusterGui(parent, filepaths, "Tooltips", tooltips);
        end
    end
end
