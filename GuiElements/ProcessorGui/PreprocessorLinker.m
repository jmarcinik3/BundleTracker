classdef PreprocessorLinker < ImagePreprocessor
    properties (Access = private)
        gui;
    end

    methods
        function obj = PreprocessorLinker(gui)
            obj@ImagePreprocessor(gui);
            configureThresholdSlider(obj, gui);
            configureInvertCheckbox(obj, gui);
            obj.gui = gui;
        end
    end

    %% Functions to retrieve GUI elements and state information
    methods
        function gui = getGui(obj)
            gui = obj.gui;
        end
    end

    %% Functions to retrieve state information
    methods (Access = protected)
        function exists = imageExists(obj)
            exists = imageExists@ImagePreprocessor(obj);
            obj.setVisible(exists);
        end
    end

    %% Functions to update state of GUI
    methods
        function invertCheckboxChanged(obj, ~, ~)
            thresholds = obj.gui.getThresholds();
            obj.updateFromRawImage(thresholds);
        end
        function thresholdSliderChanging(obj, ~, event)
            thresholds = event.Value;
            obj.updateFromRawImage(thresholds);
        end
        function thresholdSliderChanged(obj, source, ~)
            thresholds = get(source, "Value");
            obj.updateFromRawImage(thresholds);
        end
        
        function setMaximumIntensity(obj, maxIntensity)
            thresholdSlider = obj.gui.getThresholdSlider();
            updateThresholdSliderRange(thresholdSlider, maxIntensity)
        end
    end
    methods (Access = private)
        function setVisible(obj, visible)
            gl = obj.gui.getGridLayout();
            set(gl, "Visible", visible);
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

function updateThresholdSliderRange(slider, maxIntensity)
limits = [0, maxIntensity];
previousIntensity = slider.Limits(2);
previousValue = get(slider, "Value");
newValue = previousValue .* (maxIntensity / previousIntensity);

minorTicks = round(0:maxIntensity/32:maxIntensity);
majorTicks = round(0:maxIntensity/4:maxIntensity);
majorTickLabels = arrayfun(@(tick) sprintf("%d", tick), majorTicks);

set(slider, ...
    "Limits", limits, ... 
    "Value", newValue, ...
    "MinorTicks", minorTicks, ...
    "MajorTicks", majorTicks, ...
    "MajorTickLabels", majorTickLabels ...
    );
event = struct("Value", limits, "EventName", "ValueChanged");
slider.ValueChangedFcn(slider, event);
end
