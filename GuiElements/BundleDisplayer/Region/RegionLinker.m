classdef RegionLinker < PreprocessorLinker
    properties
        getRegion;
        setVisible;
    end

    properties (Access = private)
        fullRawImage;
        
        getGridLayout;
        getThresholds;
        getInvert;
        
        generatePreprocessor;
        setRawImage;
        setThresholds;
        setInvert;
    end

    methods
        function obj = RegionLinker(regionGui, region, fullRawImage)
            preprocessorGui = regionGui.getPreprocessorGui();
            regionMoverGui = regionGui.getRegionMoverGui();
            regionCompressorGui = regionGui.getRegionCompressorGui();
            regionExpanderGui = regionGui.getRegionExpanderGui();

            RegionMoverLinker(regionMoverGui, region);
            RegionCompressorLinker(regionCompressorGui, region);
            RegionExpanderLinker(regionExpanderGui, region);
            regionParser = RegionParser(region);
            obj@PreprocessorLinker(preprocessorGui);

            % inherited getters
            obj.getGridLayout = @regionGui.getGridLayout;
            obj.getRegion = @regionParser.getRegion;
            obj.getThresholds = @regionParser.getThresholds;
            obj.getInvert = @regionParser.getInvert;
            obj.generatePreprocessor = @regionParser.generatePreprocessor;

            % inherited setters
            obj.setRawImage = @preprocessorGui.setRawImage;
            obj.setVisible = @preprocessorGui.setVisible;
            obj.setThresholds = @regionParser.setThresholds;
            obj.setInvert = @regionParser.setInvert;

            % own properties
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
        end
    end
    methods (Access = protected)
        function thresholdSliderChanging(obj, source, event)
            thresholds = event.Value;
            obj.setThresholds(thresholds);
            thresholdSliderChanging@PreprocessorLinker(obj, source, event);
        end
        function thresholdSliderChanged(obj, source, event)
            thresholds = source.Value;
            obj.setThresholds(thresholds);
            thresholdSliderChanged@PreprocessorLinker(obj, source, event);
        end
        function invertCheckboxChanged(obj, source, event)
            invert = source.Value;
            obj.setInvert(invert);
            invertCheckboxChanged@PreprocessorLinker(obj, source, event);
        end
    end
    methods (Access = private)
        function regionMoving(obj, ~, ~)
            obj.updateRegionalRawImage();
        end
        function updateRegionalRawImage(obj)
            regionRawImage = obj.generateRegionalRawImage();
            obj.setRawImage(regionRawImage);
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
