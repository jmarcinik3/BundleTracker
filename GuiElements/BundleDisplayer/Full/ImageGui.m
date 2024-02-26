classdef ImageGui < PreprocessorLinker & ImageExporter & PanZoomer
    properties (Access = private)
        zoomIsEnabled;
    end

    properties
        getGridLayout;
        getFigure;
        getAxis;
        getThresholdSlider;
        getInvertCheckbox;
        getInteractiveImage;
        getRawImage;

        getRegionUserData;
        getThresholds;
        getInvert;
        imageExists;

        setRawImage;
    end

    methods
        function obj = ImageGui(parent, location, varargin)
            p = inputParser;
            addOptional(p, "EnableZoom", true);
            parse(p, varargin{:});
            enableZoom = p.Results.EnableZoom;

            gl = generateGridLayout(parent, location);
            ax = PreprocessorGui.generateAxis(gl);
            preprocessorGui = PreprocessorGui(gl, ax);

            obj@PreprocessorLinker(preprocessorGui);
            obj@ImageExporter(ax);
            obj@PanZoomer(ax);
            
            % inherited GUI getters
            obj.getGridLayout = @preprocessorGui.getGridLayout;
            obj.getFigure = @preprocessorGui.getFigure;
            obj.getAxis = @preprocessorGui.getAxis;
            obj.getThresholdSlider = @preprocessorGui.getThresholdSlider;
            obj.getInvertCheckbox = @preprocessorGui.getInvertCheckbox;
            obj.getInteractiveImage = @preprocessorGui.getInteractiveImage;
            obj.getRawImage = @preprocessorGui.getRawImage;

            % inherited state getters
            obj.getRegionUserData = @preprocessorGui.getRegionUserData;
            obj.getThresholds = @preprocessorGui.getThresholds;
            obj.getInvert = @preprocessorGui.getInvert;
            obj.imageExists = @preprocessorGui.imageExists;

            % inherited setters
            obj.setRawImage = @preprocessorGui.setRawImage;
            
            obj.zoomIsEnabled = enableZoom;

            layoutElements(obj);
        end
    end

    %% Functions to update state of GUI
    methods
        function obj = changeImage(obj, im)
            obj.setRawImage(im);
            obj.updateZoomIfEnabled();
        end
        function exportImageIfPossible(obj, startDirectory)
            if obj.imageExists()
                obj.exportImage(startDirectory);
            else
                obj.throwAlertMessage("No image imported!", "Export Image");
            end
        end
    end
    methods (Access = private)
        function updateZoomIfEnabled(obj)
            if obj.zoomIsEnabled
                obj.fitOriginalLimsToAxis(); % update zoomer for new image
            end
        end
        function throwAlertMessage(obj, message, title)
            fig = obj.getFigure();
            uialert(fig, message, title);
        end
    end
end



function layoutElements(gui)
% Set component heights in grid layout
rowHeight = TrackingGui.rowHeight;

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
set(gl, ...
    "Padding", [0, 0, 0, 0], ...
    "RowHeight", {rowHeight, '1x'}, ...
    "ColumnWidth", {'4x', '1x'} ...
    );
end

function gl = generateGridLayout(parent, location)
gl = uigridlayout(parent, [2, 1]);
gl.Layout.Row = location{1};
gl.Layout.Column = location{2};
end