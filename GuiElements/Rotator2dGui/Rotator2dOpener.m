classdef Rotator2dOpener
    methods (Static)
        function openFigure(fig, resultsFilepath)
            Rotator2dOpener.generateLinker(fig, resultsFilepath);
        end
    end

    %% Functions to generate GUI elements
    methods (Static, Access = private)
        function linker = generateLinker(fig, resultsFilepath)
            gui = Rotator2dGui(fig);
            linker = Rotator2dLinker(gui, resultsFilepath);
        end
    end
end
