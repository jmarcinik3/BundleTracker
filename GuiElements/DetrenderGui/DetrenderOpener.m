classdef DetrenderOpener
    methods (Static)
        function openFigure(fig, resultsFilepath)
            DetrenderOpener.generateLinker(fig, resultsFilepath);
        end
    end

    %% Functions to generate GUI elements
    methods (Static, Access = private)
        function linker = generateLinker(fig, resultsFilepath)
            gui = DetrenderGui(fig);
            linker = DetrenderLinker(gui, resultsFilepath);
        end
    end
end
