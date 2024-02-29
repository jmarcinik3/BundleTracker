classdef PreprocessorLinker < handle
    properties (Access = private)
        gui;
    end

    methods
        function obj = PreprocessorLinker(gui)
            obj.gui = gui;
            configureThresholdSlider(obj, gui);
            configureInvertCheckbox(obj, gui);
        end
    end

    %% Functions to generate GUI elements
    methods (Access = private)
        function processor = generatePreprocessor(obj, thresholds)
            invert = obj.gui.getInvert();
            processor = Preprocessor(thresholds, invert);
        end
    end

    %% Functions to update state of interactive image
    methods
        function setRawImage(obj, im)
            obj.gui.setRawImage(im);
            thresholds = obj.gui.getThresholds();
            obj.updateFromRawImage(thresholds);
        end
    end
    methods (Access = protected)
        function invertCheckboxChanged(obj, ~, ~)
            thresholds = obj.gui.getThresholds();
            if obj.gui.imageExists()
                obj.updateFromRawImage(thresholds);
            end
        end
        function thresholdSliderChanging(obj, ~, event)
            thresholds = event.Value;
            if obj.gui.imageExists()
                obj.updateFromRawImage(thresholds);
            end
        end
        function thresholdSliderChanged(obj, source, ~)
            thresholds = get(source, "Value");
            if obj.gui.imageExists()
                obj.updateFromRawImage(thresholds);
            end
        end
    end
    methods (Access = private)
        function updateFromRawImage(obj, thresholds)
            im = obj.generatePreprocessedImage(thresholds);
            obj.gui.showImage(im);
        end
        function im = generatePreprocessedImage(obj, thresholds)
            im = obj.gui.getRawImage();
            if obj.gui.imageExists()
                im = obj.preprocessImage(im, thresholds);
            end
        end
        function im = preprocessImage(obj, im, thresholds)
            preprocessor = obj.generatePreprocessor(thresholds);
            im = preprocessor.preprocess(im);
        end
    end
end



function configureThresholdSlider(obj, gui)
thresholdSlider = gui.getThresholdSlider();
set(thresholdSlider, ...
    "ValueChangingFcn", @obj.thresholdSliderChanging, ...
    "ValueChangedFcn", @obj.thresholdSliderChanged ...
    );
end

function configureInvertCheckbox(obj, gui)
invertCheckbox = gui.getInvertCheckbox();
set(invertCheckbox, "ValueChangedFcn", @obj.invertCheckboxChanged);
end
