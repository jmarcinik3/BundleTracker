classdef RegionPreviewer < RegionDrawer
    properties (Access = private, Constant)
        regionGuiLocation = {2, 1};
    end

    properties (Access = private)
        %#ok<*PROP>
        %#ok<*PROPLC>
        gridLayout;
        imageGui;
        tag2gui = dictionary;
        tagCounter = 0;
    end

    methods
        function obj = RegionPreviewer(parent, location, varargin)
            p = inputParser;
            addOptional(p, "EnableZoom", true);
            parse(p, varargin{:});
            enableZoom = p.Results.EnableZoom;

            gl = generateGridLayout(parent, location);
            imageGui = ImageGui(gl, {1, 1}, "EnableZoom", enableZoom);
            ax = imageGui.getAxis();
            iIm = imageGui.getInteractiveImage();

            obj@RegionDrawer(ax, @imageGui.getRegionUserData);

            set(iIm, "ButtonDownFcn", @obj.buttonDownFcn); % draw rectangles on image
            obj.gridLayout = gl;
            obj.imageGui = imageGui;
            layoutElements(obj);
        end
    end

    %% Functions to generate GUI elements
    methods (Access = private)
        function regionGui = generateRegionGui(obj, region)
            tagCounter = obj.tagCounter + 1;
            obj.tagCounter = tagCounter;
            tag = num2str(tagCounter);

            gl = obj.getGridLayout();
            location = RegionPreviewer.regionGuiLocation;
            fullRawImage = obj.getRawImage();
            regionGui = RegionGui(gl, location, region, fullRawImage);

            set(region, "Tag", tag);
            obj.tag2gui(tag) = regionGui;
        end
    end

    %% Functions to retrieve GUI elements and state information
    methods (Access = protected)
        function gui = getImageGui(obj)
            gui = obj.imageGui;
        end
        function gui = getRegionGui(obj, region)
            tag = get(region, "Tag");
            gui = obj.tag2gui(tag);
        end
        function regions = getRegions(obj)
            % Retrieves currently drawn regions on image
            imageGui = obj.getImageGui();
            ax =  imageGui.getAxis();
            regions = RegionDrawer.getRegions(ax);
        end
    end
    methods (Access = private)
        function gl = getGridLayout(obj)
            gl = obj.gridLayout;
        end
        function guis = getRegionGuis(obj)
            guis = values(obj.tag2gui);
        end
        function rawImage = getRawImage(obj)
            imageGui = obj.getImageGui();
            rawImage = imageGui.getRawImage();
        end
    end

    %% Functions to update state of GUI
    methods (Access = protected)
        function changeFullImage(obj, im)
            obj.clearRegions();
            imageGui = obj.getImageGui();
            imageGui.changeImage(im);
        end
    end
    methods (Access = private)
        function clearRegions(obj)
            % Removes currently drawn regions on image
            regions = obj.getRegions();
            fakeEvent = struct("EventName", "FakeEvent");
            arrayfun(@(region) obj.deletingRegion(region, fakeEvent), regions);
            delete(regions);
        end

        function buttonDownFcn(obj, source, event)
            if isLeftClick(event)
                region = obj.generateRegion(source, event);
                obj.generateRegionGui(region);
                obj.addListeners(region);
                obj.previewRegion(region);
            end
        end
        function addListeners(obj, region)
            addlistener(region, "ROIClicked", @obj.regionClicked);
            addlistener(region, "DeletingROI", @obj.deletingRegion);
        end
        function regionClicked(obj, source, event)
            if isLeftClick(event)
                obj.previewRegion(source);
            end
        end
        function deletingRegion(obj, source, event)
            regionGui = obj.getRegionGui(source);
            obj.removeRegionEntry(source);
            regionGui.deletingRegion(source, event);
        end

        function previewRegion(obj, region)
            obj.updateRegionGuiVisible(region);
            updateRegionColors(region);
        end
        function updateRegionGuiVisible(obj, activeRegion)
            regionGui = obj.getRegionGui(activeRegion);
            regionGuis = obj.getRegionGuis();
            arrayfun(@(gui) gui.setVisible(false), regionGuis);
            regionGui.setVisible(true);
        end
        function removeRegionEntry(obj, region)
            tag = get(region, "Tag");
            obj.tag2gui = remove(obj.tag2gui, tag);
        end
    end
end



function layoutElements(gui)
gl = gui.getGridLayout();
set(gl, "RowHeight", {'2x', '1x'})
end

function gl = generateGridLayout(parent, location)
gl = uigridlayout(parent, [2, 1]);
gl.Layout.Row = location{1};
gl.Layout.Column = location{2};
end

function is = isLeftClick(event)
name = event.EventName;
if name == "ROIClicked"
    is = event.SelectionType == "left";
elseif name == "Hit"
    is = event.Button == 1;
end
end

function updateRegionColors(activeRegion)
ax = ancestor(activeRegion, "axes");
regions = RegionDrawer.getRegions(ax);
set(regions, "Color", RegionColor.unprocessedColor);
set(activeRegion, "Color", RegionColor.workingColor);
end
