classdef AutoThresholdOpener
    methods (Static)
        function thresholdRanges = byKeyword(fig, regionalImages, keyword)
            thresholdFcn = Threshold.handleByKeyword(keyword);
            linker = AutoThresholdOpener.generateLinker(fig, regionalImages, thresholdFcn, 1);
            thresholdRanges = AutoThresholdOpener.getThresholdRanges(linker);
        end
    end

    %% Functions to generate GUI elements
    methods (Static, Access = private)
        function thresholdRanges = getThresholdRanges(linker)
            gui = linker.getGui();
            fig = gui.getFigure();
            uiwait(fig);
            thresholdRanges = linker.thresholdRanges;
        end
        function linker = generateLinker(fig, regionalImages, thresholdFcn, maxLevelCount)
            regionCount = numel(regionalImages);
            gui = AutoThresholdsGui(fig, regionCount, maxLevelCount);
            linker = AutoThresholdsLinker(gui, regionalImages, thresholdFcn);
        end
    end
end
