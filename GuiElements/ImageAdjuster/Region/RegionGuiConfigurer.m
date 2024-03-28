classdef RegionGuiConfigurer
    methods (Static, Access = ?RegionPreviewer)
        function configure(previewer, gui, region)
            configureRegionGui(previewer, gui, region);
        end
    end
end



function configureRegionGui(previewer, gui, region)
directionGui = gui.getDirectionGui();
changer = RegionChanger(previewer);
regionUserData = RegionUserData.fromRegion(region);

configureRegion(previewer, region);
configureThreshold(changer, gui, regionUserData);
configureInvert(changer, gui, regionUserData);
configureTrackingMode(changer, gui, regionUserData);
configureAngleMode(changer, gui, regionUserData);
configurePositiveDirection(changer, directionGui, regionUserData);
end

function configureThreshold(changer, gui, regionUserData)
thresholds = regionUserData.getThresholds();
thresholdSlider = gui.getThresholdSlider();
set(thresholdSlider, ...
    "ValueChangedFcn", @changer.threshold, ...
    "Value", thresholds ...
    );
addlistener(regionUserData, ...
    "IntensityRange", "PostSet", ...
    @changer.threshold ...
    );
end

function configureInvert(changer, gui, regionUserData)
invert = regionUserData.getInvert();
invertCheckbox = gui.getInvertCheckbox();
set(invertCheckbox, ...
    "ValueChangedFcn", @changer.invert, ...
    "Value", invert ...
    );
addlistener(regionUserData, ...
    "IsInverted", "PostSet", ...
    @changer.invert ...
    );
end

function configureTrackingMode(changer, gui, regionUserData)
trackingMode = regionUserData.getTrackingMode();
trackingSelection = gui.getTrackingSelectionElement();
set(trackingSelection, ...
    "ValueChangedFcn", @changer.trackingMode, ...
    "Value", trackingMode ...
    );
addlistener(regionUserData, ...
    "TrackingMode", "PostSet", ...
    @changer.trackingMode ...
    );
end

function configureAngleMode(changer, gui, regionUserData)
angleMode = regionUserData.getAngleMode();
angleSelection = gui.getAngleSelectionElement();
set(angleSelection, ...
    "ValueChangedFcn", @changer.angleMode, ...
    "Value", angleMode ...
    );
addlistener(regionUserData, ...
    "AngleMode", "PostSet", ...
    @changer.angleMode ...
    );
end

function configurePositiveDirection(changer, directionGui, regionUserData)
direction = regionUserData.getPositiveDirection();
directionElement = directionGui.getRadioGroup();
set(directionElement, "SelectionChangedFcn", @changer.positiveDirection);
directionGui.setLocation(direction);
addlistener(regionUserData, ...
    "Direction", "PostSet", ...
    @changer.positiveDirection ...
    );
end

function configureRegion(previewer, region)
addlistener(region, "MovingROI", @previewer.regionMoving);
addlistener(region, "ROIMoved", @previewer.regionMoving);
addlistener(region, "ROIClicked", @previewer.regionClicked);
addlistener(region, "DeletingROI", @previewer.deletingRegion);
end
