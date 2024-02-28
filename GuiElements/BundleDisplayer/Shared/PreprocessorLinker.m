classdef PreprocessorLinker
    properties (Access = private)
        getInvert;
        getThresholds;
        getInteractiveImage;
        getRawImage;
        imageExists;
        showImage;
        resizeAxis;
    end

    methods
        function obj = PreprocessorLinker(gui)
            % inherited getters
            obj.getInvert = @gui.getInvert;
            obj.getThresholds = @gui.getThresholds;
            obj.getInteractiveImage = @gui.getInteractiveImage;
            obj.getRawImage = @gui.getRawImage;
            obj.imageExists = @gui.imageExists;

            % inherited updaters
            obj.showImage = @gui.showImage;
            obj.resizeAxis = @gui.resizeAxis;

            obj.configureThresholdSlider(gui);
            obj.configureInvertCheckbox(gui);
        end
    end

    %% Functions to generate GUI elements
    methods (Access = private)
        function configureThresholdSlider(obj, gui)
            thresholdSlider = gui.getThresholdSlider();
            configureThresholdSlider(obj, thresholdSlider);
        end
        function configureInvertCheckbox(obj, gui)
            invertCheckbox = gui.getInvertCheckbox();
            configureInvertCheckbox(obj, invertCheckbox);
        end
        function processor = generatePreprocessor(obj, thresholds)
            invert = obj.getInvert();
            processor = Preprocessor(thresholds, invert);
        end
    end

    %% Functions to update state of interactive image
    methods (Access = protected)
        function invertCheckboxChanged(obj, ~, ~)
            thresholds = obj.getThresholds();
            if obj.imageExists()
                obj.updateFromRawImage(thresholds);
            end
        end
        function thresholdSliderChanging(obj, ~, event)
            thresholds = event.Value;
            if obj.imageExists()
                obj.updateFromRawImage(thresholds);
            end
        end
        function thresholdSliderChanged(obj, source, ~)
            thresholds = source.Value;
            if obj.imageExists()
                obj.updateFromRawImage(thresholds);
            end
        end
    end
    methods (Access = private)
        function updateFromRawImage(obj, thresholds)
            im = obj.generatePreprocessedImage(thresholds);
            obj.showImage(im);
        end
        function im = generatePreprocessedImage(obj, thresholds)
            im = obj.getRawImage();
            if obj.imageExists()
                im = obj.preprocessImage(im, thresholds);
            end
        end
        function im = preprocessImage(obj, im, thresholds)
            preprocessor = obj.generatePreprocessor(thresholds);
            im = preprocessor.preprocess(im);
        end
    end
end



function configureThresholdSlider(obj, thresholdSlider)
set(thresholdSlider, ...
    "ValueChangingFcn", @obj.thresholdSliderChanging, ...
    "ValueChangedFcn", @obj.thresholdSliderChanged ...
    );
end

function configureInvertCheckbox(obj, invertCheckbox)
set(invertCheckbox, "ValueChangedFcn", @obj.invertCheckboxChanged);
end
