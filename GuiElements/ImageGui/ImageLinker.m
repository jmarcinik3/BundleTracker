classdef ImageLinker < PreprocessorLinker ...
        & ImageAxis ...
        & AlertThrower

    methods
        function obj = ImageLinker(imageGui)
            iIm = imageGui.getInteractiveImage();
            obj@PreprocessorLinker(imageGui);
            obj@ImageAxis(iIm);
        end
    end

    %% Functions to update state of GUI
    methods
        function exportImage(obj, path)
            if obj.imageExists()
                exportImage@ImageAxis(obj, path);
            else
                obj.throwAlertMessage("No image imported!", "Export Image");
            end
        end
        function obj = changeImage(obj, im)
            obj.setRawImage(im);
            obj.setBoundsToCurrent(); % update zoomer for new image
        end
    end
end
