classdef ImageLinker < PreprocessorLinker & ImageAxis
    methods
        function obj = ImageLinker(imageGui)
            ax = imageGui.getAxis();
            iIm = imageGui.getInteractiveImage();
            obj@PreprocessorLinker(imageGui);
            obj@ImageAxis(ax, iIm);
        end
    end

    %% Functions to update state of GUI
    methods
        function exportImageIfPossible(obj, startDirectory)
            if obj.imageExists()
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
