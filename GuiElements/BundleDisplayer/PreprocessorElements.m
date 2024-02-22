classdef PreprocessorElements < handle
    properties (Access = private, Constant)
        alertRefractoryTime = 1;
    end

    properties (Access = private)
        previousAlertTime = 0;

        rawImage;
        interactiveImage;
        thresholdSlider;
        intensityThresholds;
        invertCheckbox;
    end

    methods
        function obj = PreprocessorElements(gl, ax)
            obj.interactiveImage = generateInteractiveImage(ax);
            obj.thresholdSlider = obj.generateThresholdSlider(gl);
            obj.intensityThresholds = obj.thresholdSlider.Value;
            obj.invertCheckbox = obj.generateInvertCheckbox(gl);
        end
    end

    %% Functions to generate GUI elements
    methods (Access = private)
        function thresholdSlider = generateThresholdSlider(obj, gl)
            thresholdSlider = generateThresholdSlider(gl);
            set(thresholdSlider, "ValueChangingFcn", @obj.thresholdSliderChanging)
        end
        function invertCheckbox = generateInvertCheckbox(obj, gl)
            invertCheckbox = generateInvertCheckbox(gl);
            set(invertCheckbox, "ValueChangedFcn", @obj.invertCheckboxChanged);
        end
    end

    %% Functions to retrieve GUI elements
    methods
        function elem = getThresholdSlider(obj)
            elem = obj.thresholdSlider;
        end
        function elem = getInvertCheckbox(obj)
            elem = obj.invertCheckbox;
        end
        function im = getRawImage(obj)
            im = obj.rawImage;
        end
        function iIm = getInteractiveImage(obj)
            iIm = obj.interactiveImage;
        end
    end
    methods (Access = private)
        function fig = getFigure(obj)
            iIm = obj.getInteractiveImage();
            fig = ancestor(iIm, "figure");
        end
    end

    %% Functions to retrieve state information
    methods
        function data = getPreprocessorInputs(obj)
            thresholds = obj.getThresholds();
            isInverted = obj.getInvert();
            data = struct( ...
                "IntensityRange", thresholds, ...
                "IsInverted", isInverted ...
                );
        end
        function processor = getPreprocessor(obj)
            thresholds = obj.getThresholds();
            invert = obj.getInvert();
            processor = Preprocessor(thresholds, invert);
            processor = @processor.preprocess;
        end
        function thresholds = getThresholds(obj)
            thresholds = obj.intensityThresholds;
        end
        function invert = getInvert(obj)
            invert = obj.invertCheckbox.Value;
        end
        
        function exists = imageExists(obj)
            im = obj.getRawImage();
            exists = numel(im) >= 1;
        end
    end

    %% Functions to set state information
    methods
        function setRawImage(obj, im)
            obj.rawImage = im;
            obj.updateFromRawImage();
        end
    end

    %% Functions to update state of interactive image
    methods (Access = private)
        function showImage(obj, im)
            imRgb = obj.gray2rgb(im);
            obj.setImageCData(imRgb);
        end
        function setImageCData(obj, cData)
            iIm = obj.getInteractiveImage();
            set(iIm, "CData", cData);
        end
        function imRgb = gray2rgb(obj, im)
            fig = obj.getFigure();
            imRgb = gray2rgb(im, fig);
        end

        function invertCheckboxChanged(obj, ~, ~)
            if obj.imageExists()
                obj.updateFromRawImage();
            end
        end
        function thresholdSliderChanging(obj, ~, event)
            obj.intensityThresholds = event.Value;
            if obj.imageExists()
                obj.updateFromRawImage();
            end
        end

        function updateFromRawImage(obj)
            im = obj.getPreprocessedImage();
            obj.showImage(im);
        end
        function im = getPreprocessedImage(obj)
            im = obj.getRawImage();
            if obj.imageExists()
                im = obj.preprocessImage(im);
            end
        end
        function im = preprocessImage(obj, im)
            preprocessor = obj.getPreprocessor();
            im = preprocessor(im);
        end
    end
end



%% Function to generate intensity bound input
% Generates two-value slider allowing user to set lower and upper bounds on
% image intensity
%
% Arguments
%
% * uigridlayout |gl|: layout to add slider in
%
% Returns uislider
function slider = generateThresholdSlider(gl)
slider = uislider(gl, "range");

% set major and minor tick locations
maxIntensity = 2^16; % maximum intensity for TIF image
slider.Limits = [0, maxIntensity];
slider.Value = [0, maxIntensity];
slider.MinorTicks = 0:2^11:maxIntensity;
slider.MajorTicks = 0:2^14:maxIntensity;

% format major tick labels
majorTicks = slider.MajorTicks;
tickCount = numel(majorTicks);
majorTickLabels = strings(1, tickCount);
for index = 1:tickCount
    majorTick = majorTicks(index);
    majorTickLabels(index) = sprintf("%d", majorTick);
end
slider.MajorTickLabels = majorTickLabels;
end

%% Function to generate invert checkbox
% Generates checkbox allowing user to invert image by intensity
%
% Arguments
%
% * uigridlayout |gl|: layout to add checkbox in
%
% Returns uicheckbox
function checkbox = generateInvertCheckbox(gl)
checkbox = uicheckbox(gl);
checkbox.Text = "Invert";
end

%% Function to generate plotting axis
% Generates axis on which hair cell image is plotted
%
% Arguments
%
% * uigridlayout |gl|: layout to add axis in
%
% Returns uiaxes

%% Function to generate interactive image on axis
% Generates empty image and plots onto |ax|.
% Set CData property to change image displayed on axis
%
% Arguments
%
% * uiaxes |ax|: layout to add image in
%
% Returns Image
function im = generateInteractiveImage(ax)
fig = ancestor(ax, "figure");
im = image(ax, gray2rgb([], fig)); % display RGB image
end



function rgb = gray2rgb(im, fig)
cmap = colormap(fig, "turbo");
cmap(1, :) = 0; % set dark pixels as black
cmap(end, :) = 1; % set saturated pixels as white
rgb = ind2rgb(im2uint8(im), cmap);
end