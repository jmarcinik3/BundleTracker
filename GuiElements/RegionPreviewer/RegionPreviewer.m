classdef RegionPreviewer < RegionDrawer ...
        & RegionVisibler ...
        & RegionLinker

    properties (Access = protected)
        axis;
        imageLinker;
        regionLinker;
    end

    methods
        function obj = RegionPreviewer(regionGui, imageGui)
            ax = imageGui.getAxis();
            obj@RegionVisibler(regionGui);
            obj@RegionDrawer;

            imageLinker = ImageLinker(imageGui);
            obj@RegionLinker(regionGui, imageLinker.getRawImage());
            set(imageGui.getInteractiveImage(), "ButtonDownFcn", @obj.buttonDownFcn);

            RegionMoverLinker(regionGui.getRegionMoverGui(), obj);
            RegionCompressorLinker(regionGui.getRegionCompressorGui(), obj);
            RegionExpanderLinker(regionGui.getRegionExpanderGui(), obj);

            obj.imageLinker = imageLinker;
            obj.regionLinker = obj;
            obj.axis = ax;

            obj.updateRegionalRawImage([]);
        end
    end

    %% Functions to retrieve GUI elements
    methods
        function regions = getRegions(obj)
            regions = getRegions@RegionVisibler(obj);
        end
    end
    methods (Access = protected)
        function ax = getAxis(obj)
            ax = obj.axis;
        end
    end

    %% Functions to update state of GUI
    methods
        function resetRegionButtonPushed(obj, source, ~)
            title = SettingsParser.getResetRegionLabel();
            if obj.regionExists(title)
                resetKeyword = source.UserData{1};
                region = source.UserData{2};
                obj.resetRegionsToDefaults(region, resetKeyword);
            end
        end
        function resetRegionsToDefaults(obj, regions, keyword)
            if nargin == 2
                keyword = RegionUserData.allKeyword;
            end
            if obj.regionExists()
                arrayfun( ...
                    @(region) RegionUserData(region).resetToDefaults(keyword), ...
                    regions ...
                    );
            end
        end
        function previewRegion(obj, region)
            previewRegion@RegionVisibler(obj, region);
            regionChanged(obj);
            obj.updateRegionalRawImage(region);
        end
        function duplicateRegion(obj, region)
            regionMeta = getRegionMetadata(region);
            newRegion = obj.importRegion(regionMeta);
            obj.configureRegionToGui(newRegion);
            RegionUserData.configureByRegion(newRegion, region);
        end
    end
    methods (Access = protected)
        function changeImage(obj, im)
            obj.clearRegions();
            obj.imageLinker.changeImage(im);
            changeImage@RegionLinker(obj, im);
        end

        function drawRegionsByParameters(obj, parameters, blobShape)
            taskName = ['Drawing ', blobShape, 's'];
            multiWaitbar(taskName, 0, 'CanCancel', 'on');
            regionCount = size(parameters, 1);
            regions = images.roi.Rectangle.empty(0, regionCount);

            for index = 1:regionCount
                parameter = parameters(index, :);
                region = obj.drawRegionByParameters(parameter, blobShape);
                obj.configureRegionToGui(region);
                regions(index) = region;

                proportionComplete = index / regionCount;
                if multiWaitbar(taskName, proportionComplete)
                    deleteRegions(regions);
                    break;
                end
            end

            multiWaitbar(taskName, 'Close');
        end
        function configureRegionToGui(obj, region)
            regionGui = obj.getRegionGui();
            configureRegionGui(obj, regionGui, region);
            obj.previewRegion(region);
            deleteRegionIfLine(region);
        end
    end
    methods (Access = private)
        function buttonDownFcn(obj, source, event)
            if event.Button == 1 % is left click
                region = obj.drawRegionOnClick(source, event);
                obj.configureRegionToGui(region);
            end
        end
        function regionClicked(obj, source, event)
            if event.SelectionType == "double"
                obj.resetRegionsToDefaults(source);
            end
            obj.previewRegion(source);
        end
        function regionMoving(obj, source, ~)
            obj.updateRegionalRawImage(source);
        end
        function regionMoved(obj, source, ~)
            obj.updateRegionalRawImage(source);
            deleteRegionIfLine(source);
        end
        function deletingRegion(obj, source, ~)
            activeRegion = obj.getActiveRegion();
            if ~obj.multipleRegionsExist()
                obj.updateRegionalRawImage([]);
            elseif activeRegion == source
                obj.setPreviousRegionVisible();
            end
        end

        function smoothingChanged(obj, source, event)
            switch event.EventName
                case "ValueChanged"
                    if obj.regionExists()
                        RegionUserData(obj).setSmoothing(event.Value);
                    end
                case "PostSet"
                    smoothingParserChanged(obj, source, event);
            end
        end
        function thresholdChanged(obj, source, event)
            switch event.EventName
                case "ValueChanged"
                    if obj.regionExists()
                        RegionUserData(obj).setThresholds(event.Value);
                    end
                case "PostSet"
                    thresholdParserChanged(obj, source, event);
            end
        end
        function invertChanged(obj, source, event)
            switch event.EventName
                case "ValueChanged"
                    if obj.regionExists()
                        RegionUserData(obj).setInvert(event.Value);
                    end
                case "PostSet"
                    invertParserChanged(obj, source, event);
            end
        end
        function trackingModeChanged(obj, source, event)
            switch event.EventName
                case "ValueChanged"
                    RegionUserData(obj).setTrackingMode(event.Value);
                case "PostSet"
                    trackingModeParserChanged(obj, source, event);
            end
        end
        function angleModeChanged(obj, source, event)
            switch event.EventName
                case "ValueChanged"
                    RegionUserData(obj).setAngleMode(event.Value);
                case "PostSet"
                    angleModeParserChanged(obj, source, event);
            end
        end
        function detrendModeChanged(obj, source, event)
            switch event.EventName
                case "ValueChanged"
                    RegionUserData(obj).setDetrendMode(event.Value);
                case "PostSet"
                    detrendModeParserChanged(obj, source, event);
            end
        end
        function positiveDirectionChanged(obj, source, event)
            switch event.EventName
                case "SelectionChanged"
                    direction = DirectionGui.buttonToLocation(get(source, "SelectedObject"));
                    RegionUserData(obj).setPositiveDirection(direction);
                case "PostSet"
                    directionParserChanged(obj, source, event);
            end
        end
    end

    %% Helper functions to call methods from properties
    methods
        function exportFullImage(obj, path)
            obj.imageLinker.exportImage(path);
        end
        function exportRegionImage(obj, path)
            obj.regionLinker.exportImage(path);
        end
    end
    methods (Access = protected)
        function userData = getRegionUserData(obj)
            imageGui = obj.imageLinker.getGui();
            userData = imageGui.getRegionUserData();
        end
    end
end



function configureRegionGui(previewer, gui, region)
directionGui = gui.getDirectionGui();
regionUserData = RegionUserData(region);

configureRegion(previewer, region);
configureSmoothing(previewer, gui, regionUserData);
configureThreshold(previewer, gui, regionUserData);
configureInvert(previewer, gui, regionUserData);
configureTrackingMode(previewer, gui, regionUserData);
configureAngleMode(previewer, gui, regionUserData);
configureDetrendMode(previewer, gui, regionUserData);
configurePositiveDirection(previewer, directionGui, regionUserData);
end
function configureSmoothing(previewer, gui, regionUserData)
set(gui.getSmoothingSlider(), ...
    "ValueChangedFcn", @previewer.smoothingChanged, ...
    "Value", regionUserData.getSmoothing() ...
    );
addlistener(regionUserData, "Smoothing", "PostSet", @previewer.smoothingChanged);
end
function configureThreshold(previewer, gui, regionUserData)
set(gui.getThresholdSlider(), ...
    "ValueChangedFcn", @previewer.thresholdChanged, ...
    "Value", regionUserData.getThresholds() ...
    );
addlistener(regionUserData, "IntensityRange", "PostSet", @previewer.thresholdChanged);
end
function configureInvert(previewer, gui, regionUserData)
set(gui.getInvertCheckbox(), ...
    "ValueChangedFcn", @previewer.invertChanged, ...
    "Value", regionUserData.getInvert() ...
    );
addlistener(regionUserData, "IsInverted", "PostSet", @previewer.invertChanged);
end
function configureTrackingMode(previewer, gui, regionUserData)
set(gui.getTrackingSelectionElement(), ...
    "ValueChangedFcn", @previewer.trackingModeChanged, ...
    "Value", regionUserData.getTrackingMode() ...
    );
addlistener(regionUserData, "TrackingMode", "PostSet", @previewer.trackingModeChanged);
end
function configureAngleMode(previewer, gui, regionUserData)
set(gui.getAngleSelectionElement(), ...
    "ValueChangedFcn", @previewer.angleModeChanged, ...
    "Value", regionUserData.getAngleMode() ...
    );
addlistener(regionUserData, "AngleMode", "PostSet", @previewer.angleModeChanged);
end
function configureDetrendMode(previewer, gui, regionUserData)
set(gui.getDetrendSelectionElement(), ...
    "ValueChangedFcn", @previewer.detrendModeChanged, ...
    "Value", regionUserData.getDetrendMode() ...
    );
addlistener(regionUserData, "DetrendMode", "PostSet", @previewer.detrendModeChanged);
end
function configurePositiveDirection(previewer, directionGui, regionUserData)
changedFcn = @previewer.positiveDirectionChanged;
set(directionGui.getRadioGroup(), "SelectionChangedFcn", changedFcn);
directionGui.setLocation(regionUserData.getPositiveDirection());
addlistener(regionUserData, "Direction", "PostSet", changedFcn);
end

function configureRegion(previewer, region)
addRegionListeners(previewer, region);
generateRegionMenu(previewer, region);
end
function addRegionListeners(previewer, region)
addlistener(region, "MovingROI", @previewer.regionMoving);
addlistener(region, "ROIMoved", @previewer.regionMoved);
addlistener(region, "ROIClicked", @previewer.regionClicked);
addlistener(region, "DeletingROI", @previewer.deletingRegion);
end
function generateRegionMenu(previewer, region)
if strcmpi(region.Type, "images.roi.rectangle")
    regionShape = 'Rectangle';
elseif strcmpi(region.Type, "images.roi.ellipse")
    regionShape = 'Ellipse';
elseif strcmpi(region.Type, "images.roi.polygon")
    regionShape = 'Polygon';
elseif strcmpi(region.Type, "images.roi.freehand")
    regionShape = 'Freehand';
end

cm = region.ContextMenu;
fixAspectMenu = cm.Children(2);
deleteMenu = cm.Children(1);
resetMenu = generateResetMenu(cm, previewer, region);
set(deleteMenu, "Text", ['Delete ', regionShape, '      Crtl+Del']);
set(cm, "Children", flip([resetMenu, fixAspectMenu, deleteMenu]));

uimenu(cm, ...
    "Text", ['Duplicate ', regionShape, '     Ctrl+J'], ...
    "MenuSelectedFcn", @(src, ev) previewer.duplicateRegion(region) ...
    );
uimenu(cm, ...
    "Text", ['Bring to Front', '       Ctrl+Shift+]'], ...
    "MenuSelectedFcn", @(src, ev) previewer.bringRegionToFront(region) ...
    )
uimenu(cm, ...
    "Text", ['Send to Back', '       Ctrl+Shift+['], ...
    "MenuSelectedFcn", @(src, ev) previewer.sendRegionToBack(region) ...
    )
uimenu(cm, ...
    "Text", ['Bring Forward', '               Ctrl+]'], ...
    "MenuSelectedFcn", @(src, ev) previewer.bringRegionForward(region) ...
    )
uimenu(cm, ...
    "Text", ['Send Backward', '             Ctrl+['], ...
    "MenuSelectedFcn", @(src, ev) previewer.sendRegionBackward(region) ...
    )
end
function m = generateResetMenu(parentMenu, previewer, region)
resetKeywords = RegionUserData.keywords;
m = uimenu(parentMenu, "Text", SettingsParser.getResetRegionLabel());
for index = 1:numel(resetKeywords)
    resetKeyword = resetKeywords(index);
    uimenu(m, ...
        "Text", resetKeyword, ...
        "MenuSelectedFcn", @previewer.resetRegionButtonPushed, ...
        "UserData", {resetKeyword, region} ...
        );
end
end

function regionChanged(previewer)
smoothingParserChanged(previewer);
thresholdParserChanged(previewer);
invertParserChanged(previewer);
trackingModeParserChanged(previewer);
angleModeParserChanged(previewer);
detrendModeParserChanged(previewer);
directionParserChanged(previewer);
end
function deleteRegionIfLine(region)
regionIs1d = ~sum(region.createMask(), "all");
if regionIs1d
    deleteRegions(region);
end
end

function thresholdParserChanged(previewer, ~, ~)
thresholdSlider = previewer.getRegionGui().getThresholdSlider();
thresholds = RegionUserData(previewer).getThresholds();
thresholds(1) = max(thresholds(1), thresholdSlider.Limits(1));
thresholds(2) = min(thresholds(2), thresholdSlider.Limits(2));
if size(thresholds, 1) > size(thresholds, 2)
    thresholds = thresholds.';
end

set(thresholdSlider, "Value", thresholds);
previewer.thresholdSliderChanged(thresholdSlider, []);
end

function smoothingParserChanged(previewer, ~, ~)
smoothingSlider = previewer.getRegionGui().getSmoothingSlider();
set(smoothingSlider, "Value", RegionUserData(previewer).getSmoothing());
previewer.smoothingSliderChanged(smoothingSlider, [])
end
function invertParserChanged(previewer, ~, ~)
invertCheckbox = previewer.getRegionGui().getInvertCheckbox();
set(invertCheckbox, "Value", RegionUserData(previewer).getInvert());
previewer.invertCheckboxChanged(invertCheckbox, [])
end
function trackingModeParserChanged(previewer, ~, ~)
set(previewer.getRegionGui().getTrackingSelectionElement(), ...
    "Value", RegionUserData(previewer).getTrackingMode() ...
    );
end
function angleModeParserChanged(previewer, ~, ~)
set(previewer.getRegionGui().getAngleSelectionElement(), ...
    "Value", RegionUserData(previewer).getAngleMode() ...
    );
end
function detrendModeParserChanged(previewer, ~, ~)
set(previewer.getRegionGui().getDetrendSelectionElement(), ...
    "Value", RegionUserData(previewer).getDetrendMode() ...
    );
end
function directionParserChanged(previewer, ~, ~)
direction = RegionUserData(previewer).getPositiveDirection();
directionGui = previewer.getRegionGui().getDirectionGui();
directionGui.setLocation(direction);
end
