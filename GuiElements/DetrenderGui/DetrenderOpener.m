classdef DetrenderOpener
    methods (Static)
        function detrendedTraces = openFigure(fig, traces, time)
            linker = DetrenderOpener.generateLinker(fig, traces, time);
            detrendedTraces = DetrenderOpener.getDetrendedTraces(linker);
        end
    end

    %% Functions to generate GUI elements
    methods (Static, Access = private)
        function detrendedTraces = getDetrendedTraces(linker)
            gui = linker.getGui();
            fig = gui.getFigure();
            uiwait(fig);
            detrendedTraces = linker.detrendedTraces;
        end
        function linker = generateLinker(fig, traces, time)
            windowWidthMax = size(traces, 2);
            dt = time(2) - time(1);
            gui = DetrenderGui(fig, windowWidthMax);
            linker = DetrenderLinker(gui, traces, dt);
        end
    end
end
