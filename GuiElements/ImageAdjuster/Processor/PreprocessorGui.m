classdef PreprocessorGui
    properties (Access = private)
        gridLayout;
        interactiveImage;
        thresholdSlider;
        invertCheckbox;
    end

    methods
        function obj = PreprocessorGui(gl)
            ax = generateAxis(gl);
            obj.interactiveImage = generateInteractiveImage(ax);
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
            thresholds = obj.getThresholds();
            isInverted = obj.getInvert();
            regionUserData = RegionUserData();
            regionUserData.setThresholds(thresholds);
            regionUserData.setInvert(isInverted);
        end
        function thresholds = getThresholds(obj)
            thresholds = obj.thresholdSlider.Value;
        end
        function invert = getInvert(obj)
            invert = obj.invertCheckbox.Value;
        end
    end
end



%% Function to generate plotting axis
% Generates axis on which hair cell image is plotted
%
% Arguments
%
% * uigridlayout |gl|: layout to add axis in
%
% Returns uiaxes
function ax = generateAxis(gl)
ax = uiaxes(gl);
ax.Toolbar.Visible = "off";
ax.set( ...
    "Visible", "off", ...
    "XtickLabel", [], ...
    "YTickLabel", [] ...
    );
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
majorTicks = 0:2^14:maxIntensity;
majorTickLabels = arrayfun(@(tick) sprintf("%d", tick), majorTicks);

set(slider, ...
    "Limits", [0, maxIntensity], ...
    "Value", [0, maxIntensity], ...
    "MinorTicks", 0:2^11:maxIntensity, ...
    "MajorTicks", 0:2^14:maxIntensity, ...
    "MajorTickLabels", majorTickLabels...
    );
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
