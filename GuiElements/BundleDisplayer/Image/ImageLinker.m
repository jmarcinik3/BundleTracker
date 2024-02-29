classdef ImageLinker < PreprocessorLinker & ImageAxis
    properties (Access = private)
        gui;
    end

    methods
        function obj = ImageLinker(imageGui)
            obj@PreprocessorLinker(imageGui);

            ax= imageGui.getAxis();
            iIm = imageGui.getInteractiveImage();
            obj@ImageAxis(ax, iIm);
            obj.gui = imageGui;
        end
    end

    methods
        function gui = getGui(obj)
            gui = obj.gui;
        end
    end

    %% Functions to update state of GUI
    methods
        function exportImageIfPossible(obj, startDirectory)
            if obj.gui.imageExists()
                obj.exportImage(startDirectory);
            else
                obj.throwAlertMessage("No image imported!", "Export Image");
            end
        end
        function obj = changeImage(obj, im)
            obj.setRawImage(im);
            obj.setBoundsToCurrent(); % update zoomer for new image
        end
    end
    methods (Access = private)
        function throwAlertMessage(obj, message, title)
            fig = obj.getFigure();
            uialert(fig, message, title);
        end
    end
end
