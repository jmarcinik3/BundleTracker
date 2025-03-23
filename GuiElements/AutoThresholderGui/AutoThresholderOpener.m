classdef AutoThresholderOpener
    methods (Static)
        function thresholdRanges = openFigure(fig, regionalImages)
            linker = AutoThresholderOpener.generateLinker(fig, regionalImages, 1);
            thresholdRanges = AutoThresholderOpener.getThresholdRanges(linker);
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
            gui = AutoThresholderGui(fig, numel(regionalImages), maxLevelCount);
            linker = AutoThresholderLinker(gui, regionalImages);
        end
    end
end
