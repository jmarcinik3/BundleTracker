classdef ImageGui < PreprocessorGui & ImageExporter & PanZoomer
    properties (Access = private)
        %#ok<*PROP>
        %#ok<*PROPLC>
        zoomIsEnabled;
    end

    methods
        function obj = ImageGui(parent, varargin)
            p = inputParser;
            addOptional(p, "EnableZoom", true);
            parse(p, varargin{:});
            enableZoom = p.Results.EnableZoom;

            gl = uigridlayout(parent, [2, 1]);
            ax = PreprocessorGui.generateAxis(gl);

            obj@PreprocessorGui(gl, ax);
            obj@ImageExporter(ax);
            obj@PanZoomer(ax);
            obj.zoomIsEnabled = enableZoom;

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

    %% Functions to retrieve GUI elements
    methods
        function fig = getFigure(obj)
            fig = getFigure@PreprocessorGui(obj);
        end
        function ax = getAxis(obj)
            ax = getAxis@PreprocessorGui(obj);
        end
    end

    %% Functions to update state of GUI
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
