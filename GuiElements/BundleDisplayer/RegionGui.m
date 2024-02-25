classdef RegionGui < PreprocessorGui & RegionParser
    properties (Access = private)
        %#ok<*PROP>
        %#ok<*PROPLC>
        fullRawImage;
    end

    methods
        function obj = RegionGui(parent, location, region, fullRawImage)
            gl = generateGridLayout(parent, location);
            obj@RegionParser(region);
            obj@PreprocessorGui(gl);

            addlistener(region, "MovingROI", @obj.regionMoving);
            obj.configureThresholdSlider();
            obj.configureInvertCheckbox();

            obj.fullRawImage = fullRawImage;
            obj.updateRegionalRawImage();
            layoutElements(obj);
        end
    end

    %% Functions to generate GUI elements
    methods (Access = private)
        function configureThresholdSlider(obj)
            thresholds = obj.getThresholds();
            thresholdSlider = obj.getThresholdSlider();
            set(thresholdSlider, ...
                "ValueChangingFcn", @obj.thresholdSliderChanging, ...
                "ValueChangedFcn", @obj.thresholdSliderChanged, ...
                "Value", thresholds ...
                );
        end
        function configureInvertCheckbox(obj)
            invert = obj.getInvert();
            invertCheckbox = obj.getInvertCheckbox();
            set(invertCheckbox, ...
                "ValueChangedFcn", @obj.invertCheckboxChanged, ...
                "Value", invert ...
                );
        end
    end

    %% Functions to retrieve state information
    methods (Access = protected)
        function thresholds = getThresholds(obj)
            thresholds = getThresholds@RegionParser(obj);
        end
        function invert = getInvert(obj)
            invert = getInvert@RegionParser(obj);
        end
        function processor = generatePreprocessor(obj, ~)
            processor = generatePreprocessor@RegionParser(obj);
        end
    end
    methods (Access = private)
        function regionRawImage = generateRegionalRawImage(obj)
            fullRawImage = obj.fullRawImage;
            region = obj.getRegion();
            regionRawImage = unpaddedMatrixInRegion(region, fullRawImage);
        end
    end

    %% Functions to set GUI state information
    methods
        function setVisible(obj, visible)
            gl = obj.getGridLayout();
            set(gl, "Visible", visible);
        end
    end

    %% Functions to update GUI and state information
    methods
        function deletingRegion(obj, ~, ~)
            gl = obj.getGridLayout();
            delete(gl);
            delete(obj);
        end
    end
    methods (Access = protected)
        function regionMoving(obj, ~, ~)
            obj.updateRegionalRawImage();
        end
        function updateRegionalRawImage(obj)
            regionRawImage = obj.generateRegionalRawImage();
            obj.setRawImage(regionRawImage);
        end

        function thresholdSliderChanging(obj, source, event)
            thresholdSliderChanging@PreprocessorGui(obj, source, event)
            thresholds = event.Value;
            obj.setThresholds(thresholds);
        end
        function thresholdSliderChanged(obj, source, event)
            thresholdSliderChanged@PreprocessorGui(obj, source, event)
            thresholds = source.Value;
            obj.setThresholds(thresholds);
        end
        function invertCheckboxChanged(obj, source, event)
            invertCheckboxChanged@PreprocessorGui(obj, source, event);
            invert = source.Value;
            obj.setInvert(invert);
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

function gl = generateGridLayout(parent, location)
gl = uigridlayout(parent, [1, 3]);
gl.Layout.Row = location{1};
gl.Layout.Column = location{2};
end