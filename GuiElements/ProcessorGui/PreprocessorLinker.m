classdef PreprocessorLinker < ImagePreprocessor
    properties (Access = private)
        gui;
    end

    methods
        function obj = PreprocessorLinker(gui)
            obj@ImagePreprocessor(gui);

            set( ...
                gui.getSmoothingShaper(), ...
                "ValueChangedFcn", @obj.smoothingShaperChanged, ...
                "ValueChangingFcn", @obj.smoothingShaperChanged ...
                );
            set( ...
                gui.getThresholdSlider(), ...
                "ValueChangingFcn", @obj.thresholdSliderChanged, ...
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
    methods (Access = protected)
        function invertCheckboxChanged(obj, ~, ~)
            thresholds = obj.gui.getThresholds();
            obj.updateFromRawImage(thresholds);
        end
        function thresholdSliderChanged(obj, source, ~)
            thresholds = get(source, "Value");
            obj.updateFromRawImage(thresholds);
        end
        function smoothingShaperChanged(obj, ~, ~)
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
