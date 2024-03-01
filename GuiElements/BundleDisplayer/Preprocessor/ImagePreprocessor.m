classdef ImagePreprocessor < handle
    properties (Access = private)
        gui;
    end

    methods
        function obj = ImagePreprocessor(gui)
            obj.gui = gui;
        end
    end

    %% Functions to retrieve GUI elements and state information
    methods
        function im = getRawImage(obj)
            iIm = obj.gui.getInteractiveImage();
            im = iIm.UserData.rawImage;
        end
    end

    %% Functions to generate objects
    methods (Access = private)
        function processor = generatePreprocessor(obj, thresholds)
            invert = obj.gui.getInvert();
            processor = Preprocessor(thresholds, invert);
        end
    end

    %% Functions to retrieve state information
    methods (Access = protected)
        function exists = imageExists(obj)
            im = obj.getRawImage();
            exists = numel(im) >= 1;
        end
    end

    %% Functions to update state of interactive image
    methods (Access = protected)
        function setRawImage(obj, im)
            iIm = obj.gui.getInteractiveImage();
            iIm.UserData.rawImage = im;
            thresholds = obj.gui.getThresholds();
            obj.updateFromRawImage(thresholds);
        end
        function updateFromRawImage(obj, thresholds)
            if obj.imageExists()
                im = generatePreprocessedImage(obj, thresholds);
                showImage(obj, im);
            end
        end
    end
end



function showImage(obj, im)
imRgb = obj.gui.gray2rgb(im);
iIm = obj.gui.getInteractiveImage();
set(iIm, "CData", imRgb);
end

function im = generatePreprocessedImage(obj, thresholds)
im = obj.getRawImage();
if obj.imageExists()
    preprocessor = obj.generatePreprocessor(thresholds);
    im = preprocessor.preprocess(im);
end
end
