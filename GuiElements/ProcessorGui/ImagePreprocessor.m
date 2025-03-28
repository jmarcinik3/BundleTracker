classdef ImagePreprocessor < handle
    properties (Access = private)
        gui;
    end

    methods
        function obj = ImagePreprocessor(gui)
            iIm = gui.getInteractiveImage();
            iIm.UserData.rawImage = [];
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
            processor = Preprocessor( ...
                "Smoothing", obj.gui.getSmoothing(), ...
                "Thresholds", thresholds, ...
                "Invert", obj.gui.getInvert() ...
                );
        end
    end

    %% Functions to retrieve state information
    methods (Access = protected)
        function exists = imageExists(obj)
            exists = numel(obj.getRawImage()) >= 1;
        end
    end

    %% Functions to update state of interactive image
    methods (Access = protected)
        function setRawImage(obj, im)
            iIm = obj.gui.getInteractiveImage();
            iIm.UserData.rawImage = im;
            thresholds = obj.gui.getThresholds();
            obj.setHistogramIntensity(im);
            obj.updateFromRawImage(thresholds);
        end
        function setHistogramIntensity(obj, im)
            slider = obj.gui.getThresholdSlider();
            binCount = max(round(sqrt(numel(im))), 1);
            [intensities, binEdges] = histcounts(im(:), binCount);
            binCenters = 0.5 * (binEdges(1:end-1) + binEdges(2:end));
            set( ...
                slider, ...
                "XData", mat2gray(binCenters), ...
                "YData", intensities ...
                );
        end
        function updateFromRawImage(obj, thresholds)
            if obj.imageExists()
                im = obj.getRawImage();
                preprocessor = obj.generatePreprocessor(thresholds);
                im = preprocessor.preprocess(im);
                showImage(obj, im);
            end
        end
    end
end



function showImage(obj, im)
fig = obj.gui.getFigure();
imRgb = gray2rgb(im, fig);
iIm = obj.gui.getInteractiveImage();
set(iIm, "CData", imRgb);
end
