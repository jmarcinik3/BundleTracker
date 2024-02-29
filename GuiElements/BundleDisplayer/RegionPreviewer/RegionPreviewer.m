classdef RegionPreviewer < RegionDrawer ...
        & RegionLinkerContainer ...
        & RegionOrdererHandle

    properties (Access = private)
        gridLayout;
        getRawImage;
    end

    methods
        function obj = RegionPreviewer(imageGui, regionGuiParent)
            ax = imageGui.getAxis();
            iIm = imageGui.getInteractiveImage();

            obj@RegionLinkerContainer(imageGui, regionGuiParent);
            obj@RegionDrawer(ax, @imageGui.getRegionUserData);
            obj@RegionOrdererHandle();

            % inherited functions
            obj.getRawImage = @imageGui.getRawImage;

            set(iIm, "ButtonDownFcn", @obj.buttonDownFcn); % draw rectangles on image
        end
    end

    methods
        function regions = getRegions(obj)
            regions  = getRegions@RegionLinkerContainer(obj);
        end
    end

    %% Functions to generate GUI elements
    methods (Access = private)
        function regionLinker = generateRegionLinker(obj, region)
            fullRawImage = obj.getRawImage();
            regionGui = obj.generateRegionGui();
            regionLinker = RegionLinker(regionGui, region, fullRawImage);
            obj.addRegionEntry(regionLinker);
        end
    end

    %% Functions to retrieve GUI elements
    methods (Access = private)
        function previousRegion = getPreviousRegion(obj)
            currentRegion = obj.getCurrentRegion();
            regions = obj.getRegions();

            currentIndex = str2double(get(currentRegion, "Tag"));
            regionIndices = str2double(get(regions, "Tag"));
            previousIndex = getPreviousFloatCyclic(regionIndices, currentIndex);
            previousTag = num2str(previousIndex);
            previousRegion = findobj(regions, "Tag", previousTag);
        end
        function nextRegion = getNextRegion(obj)
            currentRegion = obj.getCurrentRegion();
            regions = obj.getRegions();

            currentIndex = str2double(get(currentRegion, "Tag"));
            regionIndices = str2double(get(regions, "Tag"));
            nextIndex = getNextFloatCyclic(regionIndices, currentIndex);
            nextTag = num2str(nextIndex);
            nextRegion = findobj(regions, "Tag", nextTag);
        end
    end

    %% Functions to update state of GUI
    methods
        function setPreviousRegionVisible(obj, ~, ~)
            currentRegion = obj.getCurrentRegion();
            if objectIsValid(currentRegion)
                nextRegion = obj.getPreviousRegion();
                obj.previewRegion(nextRegion);
            elseif obj.regionExists()
                obj.setFirstRegionVisible();
            end
        end
        function setNextRegionVisible(obj, ~, ~)
            currentRegion = obj.getCurrentRegion();
            if objectIsValid(currentRegion)
                nextRegion = obj.getNextRegion();
                obj.previewRegion(nextRegion);
            elseif obj.regionExists()
                obj.setFirstRegionVisible();
            end
        end
    end
    methods (Access = private)
        function buttonDownFcn(obj, source, event)
            if isLeftClick(event)
                region = obj.generateRegion(source, event);
                obj.generateRegionLinker(region);
                obj.addListeners(region);
                obj.previewRegion(region);
            end
        end
        function addListeners(obj, region)
            addlistener(region, "ROIClicked", @obj.regionClicked);
        end
        function regionClicked(obj, source, event)
            if isLeftClick(event)
                obj.previewRegion(source);
            end
        end

        function previewRegion(obj, region)
            obj.setCurrentRegion(region);
            obj.updateRegionGuiVisible(region);
            updateRegionColors(region);
        end
        function updateRegionGuiVisible(obj, activeRegion)
            regionLinker = obj.getRegionLinker(activeRegion);
            regionLinkers = obj.getRegionLinkers();
            arrayfun(@(gui) gui.setVisible(false), regionLinkers);
            regionLinker.setVisible(true);
        end

        function setFirstRegionVisible(obj)
            regions = obj.getRegions();
            firstRegion = regions(1);
            obj.previewRegion(firstRegion);
        end
    end
end



function is = isLeftClick(event)
name = event.EventName;
if name == "ROIClicked"
    is = event.SelectionType == "left";
elseif name == "Hit"
    is = event.Button == 1;
end
end

function isValid = objectIsValid(obj)
isValid = ~isempty(obj) && isvalid(obj);
end

function updateRegionColors(activeRegion)
ax = ancestor(activeRegion, "axes");
regions = RegionDrawer.getRegions(ax);
set(regions, "Color", RegionColor.unprocessedColor);
set(activeRegion, "Color", RegionColor.workingColor);
end

function nextFloat = getNextFloatCyclic(array, number)
greaterFloats = array(array > number);
existsGreaterFloat = numel(greaterFloats) >= 1;
if existsGreaterFloat
    nextFloat = min(greaterFloats);
else
    nextFloat = array(1);
end
end

function previousFloat = getPreviousFloatCyclic(array, number)
lesserFloats = array(array < number);
existsGreaterFloat = numel(lesserFloats) >= 1;
if existsGreaterFloat
    previousFloat = max(lesserFloats);
else
    previousFloat = array(end);
end
end
