classdef RegionGui < PreprocessorGui
    properties (Access = private)
        %#ok<*PROP>
        %#ok<*PROPLC>
        rawImage;
        regionParser;
    end

    methods
        function obj = RegionGui(parent)
            gl = uigridlayout(parent, [1, 3]);
            obj@PreprocessorGui(gl);
            
            thresholdSlider = obj.getThresholdSlider();
            invertCheckbox = obj.getInvertCheckbox();
            set(thresholdSlider, "ValueChangedFcn", @obj.thresholdSliderChanged);
            set(invertCheckbox, "ValueChangedFcn", @obj.invertCheckboxChanged);
            layoutElements(obj);
        end
    end

    %% Functions to retreive state information
    methods (Access = private)
        function region = getRegion(obj)
            region = obj.regionParser.getRegion();
        end
        function thresholds = getRegionThresholds(obj)
            thresholds = obj.regionParser.getThresholds();
        end
        function invert = getRegionInvert(obj)
            invert = obj.regionParser.getInvert();
        end
    end

    %% Functions to set state information
    methods
        function setRegion(obj, region, rawImage)
            obj.regionParser = RegionParser(region); % must come before updating GUI
            obj.updateThresholdSlider();
            obj.updateInvertCheckbox();
            obj.setRawImage(rawImage);
        end
    end
    methods (Access = private)
        function setRegionThresholds(obj, thresholds)
            obj.regionParser.setThresholds(thresholds);
        end
        function setRegionInvert(obj, invert)
            obj.regionParser.setInvert(invert);
        end
    end

    %% Functions to update GUI and state information
    methods (Access = protected)
        function thresholdSliderChanged(obj, source, event)
            thresholdSliderChanged@PreprocessorGui(obj, source, event)
            thresholds = source.Value;
            obj.setRegionThresholds(thresholds);
        end
        function invertCheckboxChanged(obj, source, event)
            invertCheckboxChanged@PreprocessorGui(obj, source, event);
            invert = source.Value;
            obj.setRegionInvert(invert);
        end
    end
    methods (Access = private)
        function updateThresholdSlider(obj)
            thresholds = obj.getRegionThresholds();
            thresholdSlider = obj.getThresholdSlider();
            event = struct("EventName", "RegionChanged");
            set(thresholdSlider, "Value", thresholds);
            obj.thresholdSliderChanged(thresholdSlider, event);
        end
        function updateInvertCheckbox(obj)
            invert = obj.getRegionInvert();
            invertCheckbox = obj.getInvertCheckbox();
            set(invertCheckbox, "Value", invert);
        end
    end
end



function layoutElements(gui)
% Set component heights in grid layout
rowHeight = TrackingGui.rowHeight;

% Retrieve components
gl = gui.getGridLayout();
ax = gui.getAxis();
thresholdSlider = gui.getThresholdSlider();
invertCheckbox = gui.getInvertCheckbox();

ax.Layout.Row = [1, 3];
ax.Layout.Column = 1;
thresholdSlider.Layout.Row = 1;
thresholdSlider.Layout.Column = 2;
invertCheckbox.Layout.Row = 2;
invertCheckbox.Layout.Column = 2;

% Set up row heights and column widths for grid layout
gl.RowHeight = {rowHeight, rowHeight, '1x'};
gl.ColumnWidth = {'1x', '2x'};
end
