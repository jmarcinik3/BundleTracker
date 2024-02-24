classdef RegionPreviewer < RectangleDrawer
    properties (Access = private)
        %#ok<*PROP>
        %#ok<*PROPLC>
        gridLayout;
        imageGui;
        regionGui;
    end

    methods
        function obj = RegionPreviewer(parent, location, varargin)
            p = inputParser;
            addOptional(p, "EnableZoom", true);
            parse(p, varargin{:});
            enableZoom = p.Results.EnableZoom;

            gl = generateGridLayout(parent, location);
            regionGui = RegionGui(gl, {2, 1});
            imageGui = ImageGui(gl, {1, 1}, "EnableZoom", enableZoom);
            ax = imageGui.getAxis();
            iIm = imageGui.getInteractiveImage();

            obj@RectangleDrawer(ax, @imageGui.getRegionUserData);

            set(iIm, "ButtonDownFcn", @obj.buttonDownFcn); % draw rectangles on image
            obj.gridLayout = gl;
            obj.imageGui = imageGui;
            obj.regionGui = regionGui;
            layoutElements(obj);
        end
    end

    %% Functions to retrieve GUI elements and state information
    methods (Access = protected)
        function gui = getImageGui(obj)
            gui = obj.imageGui;
        end
        function gui = getRegionGui(obj)
            gui = obj.regionGui;
        end
        function rects = getRegions(obj)
            % Retrieves currently drawn regions on image
            imageGui = obj.getImageGui();
            ax =  imageGui.getAxis();
            rects = getRegions(ax);
        end
    end
    methods (Access = private)
        function gl = getGridLayout(obj)
            gl = obj.gridLayout;
        end
        function elem = getImageElement(obj)
            imageGui = obj.getImageGui();
            elem = imageGui.getGridLayout();
        end
        function elem = getRegionElement(obj)
            regionGui = obj.getRegionGui();
            elem = regionGui.getGridLayout();
        end
    end

    %% Functions to update state of GUI
    methods (Access = protected)
        function changeFullImage(obj, im)
            imageGui = obj.getImageGui();
            regionGui = obj.getRegionGui();
            imageGui.changeImage(im);
            regionGui.setRawImage([]);
        end
        function clearRegions(obj)
            % Removes currently drawn regions on image
            regions = obj.getRegions();
            delete(regions);
        end
    end
    methods (Access = private)
        function buttonDownFcn(obj, source, event)
            if isLeftClick(event)
                rect = obj.generateRectangle(source, event);
                obj.previewGeneratedRegion(rect);
            end
        end
        function previewGeneratedRegion(obj, region)
            obj.addListeners(region);
            obj.setPreviewRegion(region);
        end

        function addListeners(obj, region)
            addlistener(region, "ROIClicked", @obj.regionClicked);
            addlistener(region, "MovingROI", @obj.regionMoving);
        end
        function regionMoving(obj, source, ~)
            obj.setPreviewRegion(source);
        end
        function regionClicked(obj, source, event)
            if isLeftClick(event)
                obj.setPreviewRegion(source);
            end
        end

        function setPreviewRegion(obj, region)
            regionGui = obj.getRegionGui();
            regionRawImage = obj.getRegionalRawImage(region);
            regionGui.setRegion(region, regionRawImage);
            obj.updateRegionColors(region);
        end
        function regionRawImage = getRegionalRawImage(obj, region)
            imageGui = obj.getImageGui();
            im = imageGui.getRawImage();
            regionRawImage = unpaddedMatrixInRegion(region, im);
        end

        function updateRegionColors(obj, activeRegion)
            regions = obj.getRegions();
            updateRegionColors(activeRegion, regions);
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

function rects = getRegions(ax)
children = ax.Children;
rects = findobj(children, "Type", "images.roi.rectangle");
rects = flip(rects);
end
function updateRegionColors(activeRegion, regions)
set(regions, "Color", RegionColor.unprocessedColor);
set(activeRegion, "Color", RegionColor.workingColor);
end
