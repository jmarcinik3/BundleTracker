classdef PreprocessorGui
    properties (Access = private)
        gridLayout;
        interactiveImage;
        smoothingShaper;
        thresholdSlider;
        invertCheckbox;
    end

    methods
        function obj = PreprocessorGui(gl)
            ax = generateEmptyAxis(gl);
            obj.interactiveImage = generateInteractiveImage(ax);
            obj.smoothingShaper = generateSmoothingShaper(gl);
            obj.thresholdSlider = generateThresholdSlider(gl);
            obj.invertCheckbox = generateInvertCheckbox(gl);
            obj.gridLayout = gl;
        end
    end

    %% Functions to retrieve GUI elements
    methods
        function fig = getFigure(obj)
            iIm = obj.getInteractiveImage();
            fig = ancestor(iIm, "figure");
        end
        function gl = getGridLayout(obj)
            gl = obj.gridLayout;
        end
        function ax = getAxis(obj)
            iIm = obj.getInteractiveImage();
            ax = ancestor(iIm, "axes");
        end
        function elem = getSmoothingShaper(obj)
            elem = obj.smoothingShaper;
        end
        function elem = getThresholdSlider(obj)
            elem = obj.thresholdSlider;
        end
        function elem = getInvertCheckbox(obj)
            elem = obj.invertCheckbox;
        end
        function iIm = getInteractiveImage(obj)
            iIm = obj.interactiveImage;
        end
    end

    %% Functions to retrieve state information
    methods
        function regionUserData = getRegionUserData(obj)
            smoothing = obj.getSmoothing();
            thresholds = obj.getThresholds();
            isInverted = obj.getInvert();
            
            regionUserData = RegionUserData();
            regionUserData.setSmoothing(smoothing);
            regionUserData.setThresholds(thresholds);
            regionUserData.setInvert(isInverted);
        end
        function smoothing = getSmoothing(obj)
            smoothing = get(obj.smoothingShaper, "WindowSize");
        end
        function thresholds = getThresholds(obj)
            thresholds = obj.thresholdSlider.Value;
        end
        function invert = getInvert(obj)
            invert = obj.invertCheckbox.Value;
        end
    end
end



%% Function to generate intensity bound input
% Generates element allowing user to set width of smoothing window
%
% Arguments
%
% * uigridlayout |gl|: layout to add slider in
%
% Returns uislider
function shaper = generateSmoothingShaper(gl)
defaults = SettingsParser.getSmoothingShaperDefaults();
shaper = WindowShaper(gl);
set(shaper, defaults{:}, "IncludeTitle", false);
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
defaults = SettingsParser.getThresholdSliderDefaults();
slider = RangePlotSlider(gl);
set(slider, defaults{:});
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
defaults = SettingsParser.getInvertCheckboxDefaults();
checkbox = uicheckbox(gl, defaults{:});
end

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
