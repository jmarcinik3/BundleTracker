classdef AutoThresholdOpener
    methods (Static)
        function thresholdRanges = openFigure(fig, regionalImages)
            linker = AutoThresholdOpener.generateLinker(fig, regionalImages, 1);
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
        function linker = generateLinker(fig, regionalImages, maxLevelCount)
            regionCount = numel(regionalImages);
            gui = AutoThresholdsGui(fig, regionCount, maxLevelCount);
            linker = AutoThresholdsLinker(gui, regionalImages);
        end
    end
end
