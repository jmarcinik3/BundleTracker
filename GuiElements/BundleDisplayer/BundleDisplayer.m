classdef BundleDisplayer < PreprocessorElements & RectangleDrawer & PanZoomer
    properties (Access = private)
        %#ok<*PROP>
        %#ok<*PROPLC>

        gridLayout;
        doZoom;
    end

    methods
        function obj = BundleDisplayer(parent, varargin)
            p = inputParser;
            addOptional(p, "EnableZoom", true);
            parse(p, varargin{:});
            enableZoom = p.Results.EnableZoom;

            gl = uigridlayout(parent, [2, 1]);
            ax = generateAxis(gl);

            obj@PreprocessorElements(gl, ax);
            obj@RectangleDrawer(ax);
            obj@PanZoomer(ax);

            obj.setUserDataFcn(@obj.getRegionUserData);
            obj.doZoom = enableZoom;

            obj.gridLayout = gl;
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
            obj.resizeAxis();
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
        function gl = getGridLayout(obj)
            gl = obj.gridLayout;
        end
    end

    %% Functions to retrieve information of GUI
    methods (Access = private)
        function [h, w] = getImageSize(obj)
            im = obj.getRawImage();
            [h, w] = size(im);
        end
        function is = zoomIsEnabled(obj)
            is = obj.doZoom;
        end
    end

    %% Functions to update state of GUI
    methods (Access = private)
        function buttonDownFcn(obj, source, event)
            mouseButton = event.Button;
            if isLeftClick(mouseButton)
                obj.generateRectangle(source, event);
            end
        end
        function data = getRegionUserData(obj)
            thresholds = obj.getThresholds();
            isInverted = obj.getInvert();
            data = struct( ...
                "IntensityRange", thresholds, ...
                "IsInverted", isInverted ...
                );
        end

        function resizeAxis(obj)
            ax = obj.getAxis();
            [h, w] = obj.getImageSize();
            resizeAxis(ax, h, w);
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



function layoutElements(bundleDisplay)
% Set component heights in grid layout
sliderHeight = 30;

% Retrieve components
gl = bundleDisplay.getGridLayout();
thresholdSlider = bundleDisplay.getThresholdSlider();
invertCheckbox = bundleDisplay.getInvertCheckbox();
ax = bundleDisplay.getAxis();

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
function ax = generateAxis(gl)
ax = uiaxes(gl);
ax.Visible = "off";
ax.Toolbar.Visible = "off";
end

function is = isLeftClick(mouseButton)
is = mouseButton == 1;
end
