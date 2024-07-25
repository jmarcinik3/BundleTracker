classdef PreprocessorLinker < ImagePreprocessor
    properties (Access = private)
        gui;
    end

    methods
        function obj = PreprocessorLinker(gui)
            obj@ImagePreprocessor(gui);

            set(gui.getSmoothingSlider(), "ValueChangedFcn", @obj.smoothingSliderChanged);
            set(gui.getThresholdSlider(), ...
                "ValueChangingFcn", @obj.thresholdSliderChanging, ...
                "ValueChangedFcn", @obj.thresholdSliderChanged ...
                );
            set(gui.getInvertCheckbox(), "ValueChangedFcn", @obj.invertCheckboxChanged);

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
        function setMaximumIntensity(obj, maxIntensity)
            thresholdSlider = obj.gui.getThresholdSlider();
            updateThresholdSliderRange(thresholdSlider, maxIntensity)
        end
    end
    methods (Access = protected)
        function invertCheckboxChanged(obj, ~, ~)
            thresholds = obj.gui.getThresholds();
            obj.updateFromRawImage(thresholds);
        end
        function thresholdSliderChanging(obj, ~, event)
            thresholds = event.Value;
            obj.updateFromRawImage(thresholds);
        end
        function thresholdSliderChanged(obj, source, ~)
            thresholds = round(get(source, "Value"));
            set(source, "Value", thresholds);
            obj.updateFromRawImage(thresholds);
        end
        function smoothingSliderChanged(obj, source, ~)
            smoothing = round(get(source, "Value"));
            set(source, "Value", smoothing);
            thresholds = obj.gui.getThresholds();
            obj.updateFromRawImage(thresholds);
        end
    end
    methods (Access = private)
        function setVisible(obj, visible)
            gl = obj.gui.getGridLayout();
            set(gl, "Visible", visible);
        end
    end
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
