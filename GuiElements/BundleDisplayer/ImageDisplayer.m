classdef ImageDisplayer < PreprocessorElements & RectangleDrawer & PanZoomer
    properties (Access = private)
        %#ok<*PROP>
        %#ok<*PROPLC>
        regionDisplayer;
        doZoom;
    end

    methods
        function obj = ImageDisplayer(parent, varargin)
            p = inputParser;
            addOptional(p, "EnableZoom", true);
            parse(p, varargin{:});
            enableZoom = p.Results.EnableZoom;

            gl = uigridlayout(parent, [2, 1]);
            ax = PreprocessorElements.generateAxis(gl);

            obj@PreprocessorElements(gl, ax);
            obj@RectangleDrawer(ax);
            obj@PanZoomer(ax);

            obj.regionDisplayer = RegionDisplayer(parent);
            obj.setUserDataFcn(@obj.getRegionUserData);
            obj.doZoom = enableZoom;

            iIm = obj.getInteractiveImage();
            set(iIm, "ButtonDownFcn", @obj.buttonDownFcn); % draw rectangles on image
            layoutElements(obj);
        end

        function clearRegions(obj)
            % Removes currently drawn regions on image
            regions = obj.getRegions();
            delete(regions);
        end
        function rects = getRegions(obj)
            % Retrieves currently drawn regions on image
            ax =  obj.getAxis();
            children = ax.Children;
            rects = findobj(children, "Type", "images.roi.rectangle");
        end

        function obj = changeImage(obj, im)
            obj.setRawImage(im);
            obj.regionDisplayer.setRawImage(im);
            obj.updateZoomIfNeeded();
        end

        function exportImageIfPossible(obj, startDirectory)
            if obj.imageExists()
                obj.exportImage(startDirectory);
            else
                obj.throwAlertMessage("No image imported!", "Export Image");
            end
        end
    end

    %% Functions to retrieve GUI elements
    methods
        function fig = getFigure(obj)
            fig = getFigure@PreprocessorElements(obj);
        end
        function displayer = getRegionDisplayer(obj)
            displayer = obj.regionDisplayer;
        end
    end
    methods (Access = protected)
        function ax = getAxis(obj)
            ax = getAxis@PreprocessorElements(obj);
        end
    end

    %% Functions to retrieve information of GUI
    methods (Access = private)
        function is = zoomIsEnabled(obj)
            is = obj.doZoom;
        end
    end

    %% Functions to update state of GUI
    methods (Access = private)
        function buttonDownFcn(obj, source, event)
            if isLeftClick(event)
                rect = obj.generateRectangle(source, event);
                obj.addRegionListeners(rect);
                obj.setRegionInDisplayer(rect);
            end
        end
        function addRegionListeners(obj, region)
            addlistener(region, "MovingROI", @obj.regionMoving);
            addlistener(region, "ROIClicked", @obj.regionClicked);
        end
        function regionMoving(obj, source, ~)
            obj.setRegionInDisplayer(source);
        end
        function regionClicked(obj, source, event)
            if isLeftClick(event)
                obj.setRegionInDisplayer(source);
            end
        end
        function setRegionInDisplayer(obj, region)
            regionRawImage = obj.getRegionalRawImage(region);
            obj.regionDisplayer.setRegion(region, regionRawImage);
        end
        function regionRawImage = getRegionalRawImage(obj, region)
            im = obj.getRawImage();
            regionRawImage = unpaddedMatrixInRegion(region, im);
        end

        function updateZoomIfNeeded(obj)
            if obj.zoomIsEnabled()
                obj.fitOriginalLimsToAxis(); % update zoomer for new image
            end
        end
        function exportImage(obj, startDirectory)
            ax = obj.getAxis();
            ImageExporter.export(ax, startDirectory);
        end
        function throwAlertMessage(obj, message, title)
            fig = obj.getFigure();
            uialert(fig, message, title);
        end
    end
end



function layoutElements(gui)
% Set component heights in grid layout
sliderHeight = 30;

% Retrieve components
gl = gui.getGridLayout();
thresholdSlider = gui.getThresholdSlider();
invertCheckbox = gui.getInvertCheckbox();
ax = gui.getAxis();

% Set up slider for intensity threshold to left of invert checkbox
thresholdSlider.Layout.Row = 1;
thresholdSlider.Layout.Column = 1;
invertCheckbox.Layout.Row = 1;
invertCheckbox.Layout.Column = 2;

% Set up axis on which bundles are displayed
ax.Layout.Row = 2;
ax.Layout.Column = [1 2];

% Set up row heights and column widths for grid layout
gl.RowHeight = {sliderHeight, '1x'};
gl.ColumnWidth = {'4x', '1x'};
end

function is = isLeftClick(event)
name = event.EventName;
if name == "ROIClicked"
    is = event.SelectionType == "left";
elseif name == "Hit"
    is = event.Button == 1;
end
end

function unpaddedMatrix = unpaddedMatrixInRegion(region, im)
regionMask = createMask(region, im);
im(regionMask == 0) = 0;
unpaddedMatrix = unpadMatrix(im);
end
function unpaddedMatrix = unpadMatrix(matrix)
[nonzeroRows, nonzeroColumns] = find(matrix);
nonzeroRowsSlice = min(nonzeroRows):max(nonzeroRows);
nonzeroColumnsSlice = min(nonzeroColumns):max(nonzeroColumns);
unpaddedMatrix = matrix(nonzeroRowsSlice, nonzeroColumnsSlice);
end
