classdef RegionLinker
    properties (Access = private)
        fullRawImage;
        preprocessorLinker;
        regionParser;
    end

    properties
        getGridLayout;
        getRegion;
        getThresholds;
        getInvert;
        generatePreprocessor;

        setRawImage;
        setVisible;
    end

    methods
        function obj = RegionLinker(regionGui, region, fullRawImage)
            preprocessorGui = regionGui.getPreprocessorGui();
            regionMoverGui = regionGui.getRegionMoverGui();
            preprocessorLinker = PreprocessorLinker(preprocessorGui);
            RegionMoverLinker(regionMoverGui, region);
            regionParser = RegionParser(region);

            % inherited getters
            obj.getGridLayout = @regionGui.getGridLayout;
            obj.getRegion = @regionParser.getRegion;
            obj.getThresholds = @regionParser.getThresholds;
            obj.getInvert = @regionParser.getInvert;
            obj.generatePreprocessor = @regionParser.generatePreprocessor;

            % inherited setters
            obj.setRawImage = @preprocessorGui.setRawImage;
            obj.setVisible = @preprocessorGui.setVisible;

            obj.preprocessorLinker = preprocessorLinker;
            obj.regionParser = regionParser;
            obj.fullRawImage = fullRawImage;

            % configure GUI elements, must come last
            configureRegion(obj, region);
            configureThresholdSlider(obj, preprocessorGui, regionParser);
            configureInvertCheckbox(obj, preprocessorGui, regionParser);
            obj.updateRegionalRawImage();
        end
    end

    %% Functions to retrieve state information
    methods (Access = private)
        function regionRawImage = generateRegionalRawImage(obj)
            fullRawImage = obj.fullRawImage;
            region = obj.getRegion();
            regionRawImage = unpaddedMatrixInRegion(region, fullRawImage);
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
            thresholds = event.Value;
            obj.regionParser.setThresholds(thresholds);
            obj.preprocessorLinker.thresholdSliderChanging(source, event);
        end
        function thresholdSliderChanged(obj, source, event)
            thresholds = source.Value;
            obj.regionParser.setThresholds(thresholds);
            obj.preprocessorLinker.thresholdSliderChanged(source, event);
        end
        function invertCheckboxChanged(obj, source, event)
            invert = source.Value;
            obj.regionParser.setInvert(invert);
            obj.preprocessorLinker.invertCheckboxChanged(source, event);
        end
    end
end


%% Functions to configure GUI elements
function configureThresholdSlider(obj, gui, regionParser)
thresholds = regionParser.getThresholds();
thresholdSlider = gui.getThresholdSlider();
set(thresholdSlider, ...
    "ValueChangingFcn", @obj.thresholdSliderChanging, ...
    "ValueChangedFcn", @obj.thresholdSliderChanged, ...
    "Value", thresholds ...
    );
end
function configureInvertCheckbox(obj, gui, regionParser)
invert = regionParser.getInvert();
invertCheckbox = gui.getInvertCheckbox();
set(invertCheckbox, ...
    "ValueChangedFcn", @obj.invertCheckboxChanged, ...
    "Value", invert ...
    );
end
function configureRegion(obj, region)
addlistener(region, "MovingROI", @obj.regionMoving);
addlistener(region, "ROIMoved", @obj.regionMoving);
end
