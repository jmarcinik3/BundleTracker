classdef BundleDisplay < PanZoomer
    properties (Access = private)
        %#ok<*PROP>
        %#ok<*PROPLC>
        
        gridLayout;
        axis; % uiaxes on which image is plotted
        interactiveImage = [];  % image object containing pixel data and drawn regions
        rawImage = [];
        axisWidth = 0;
        axisHeight = 0;

        thresholdSlider;
        intensityThresholds;
        invertCheckbox

        doZoom;
    end

    properties (Access = private, Constant)
        imageExtensions = { ...
            '*.png', "Portable Network Graphics (PNG)"; ...
            '*.jpg;*.jpeg', "Joint Photographic Experts Group (JPEG)"; ...
            '*.tif;*.tiff', "Tagged Image File Format (TIFF)"; ...
            '*.gif', "Graphics Interchange Format (GIF)"; ...
            '*.eps', "Encapsulated PostScript® (EPS)"; ...
            '*.pdf', "Portable Document Format (PDF)";
            '*.emf', "Enhanced Metafile for Windows® systems only (EMF)";
            }; % compatible extensions to save image as
        unprocessedColor = [0 0.4470 0.7410]; % default rectangle color
    end

    methods
        function obj = BundleDisplay(parent, varargin)
            p = inputParser;
            addOptional(p, "EnableZoom", true);
            parse(p, varargin{:});
            enableZoom = p.Results.EnableZoom;
            
            gl = uigridlayout(parent, [2, 1]);

            ax = generateAxis(gl);
            obj@PanZoomer(ax);
            obj.doZoom = enableZoom;
            
            obj.gridLayout = gl;
            obj.axis = ax;
            obj.interactiveImage = obj.generateInteractiveImage(ax);
            obj.thresholdSlider = obj.generateThresholdSlider(gl);
            obj.intensityThresholds = obj.thresholdSlider.Value;
            obj.invertCheckbox = obj.generateInvertCheckbox(gl);
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
            rects = getRegionsFromAxis(ax);
        end
        function obj = changeImage(obj, im)
            obj.rawImage = im;
            obj.updateFromRawImage();
            obj.resizeAxisIfNeeded();
        end
        function saveImage(obj, startDirectory)
            % Saves currently displayed bundle image and drawn regions
            if obj.imageExists()
                extensions = BundleDisplay.imageExtensions;
                ax = obj.getAxis();
                saveImageOnAxis(ax, extensions, startDirectory);
            end
        end
        function exists = imageExists(obj)
            im = obj.getRawImage();
            exists = numel(im) >= 1;
            if ~exists
                obj.throwAlertMessage("No image imported!", "Save Image");
            end
        end

        function gl = getGridLayout(obj)
            gl = obj.gridLayout;
        end
        function ax = getAxis(obj)
            % Retrieves uiaxes on which image is plotted
            ax = obj.axis;
        end
    end

    methods (Access = private)
        function thresholdSlider = generateThresholdSlider(obj, gl)
            thresholdSlider = generateThresholdSlider(gl);
            set(thresholdSlider, "ValueChangingFcn", @obj.thresholdSliderChanging)
        end
        function invertCheckbox = generateInvertCheckbox(obj, gl)
            invertCheckbox = generateInvertCheckbox(gl);
            set(invertCheckbox, "ValueChangedFcn", @obj.invertCheckboxChanged);
        end
        function iIm = generateInteractiveImage(obj, ax)
            iIm = generateImage(ax);
            set(iIm, "ButtonDownFcn", @obj.buttonDownFcn); % draw rectangles on image
        end
    end

    methods (Access = private)
        function buttonDownFcn(obj, source, event)
            mouseButton = event.Button;
            if isLeftClick(mouseButton)
                obj.generateRectangle(source, event);
            end
        end
        function generateRectangle(obj, ~, event)
            point = event.IntersectionPoint(1:2);
            rect = obj.drawRectangle(point);
            obj.formatRectangle(rect);
            obj.updateRegionLabels();
        end
        function rect = drawRectangle(obj, point)
            ax = obj.getAxis();
            rect = drawRectangle(ax, point);
        end
        function formatRectangle(obj, rect)
            color = obj.unprocessedColor;
            set(rect, "Color", color);
            addlistener( ...
                rect, "ROIClicked", ...
                @(src, ev) rect.set("Color", color) ...
                );
        end
        function updateRegionLabels(obj)
            regions = flip(obj.getRegions());
            count = numel(regions);
            for index = 1:count
                region = regions(index);
                label = num2str(index);
                set(region, "Label", label);
            end
        end

        function showImage(obj, im)
            imRgb = obj.gray2rgb(im);
            obj.setImageCData(imRgb);
        end
        function imRgb = gray2rgb(obj, im)
            fig = obj.getFigure();
            imRgb = gray2rgb(im, fig);
        end

        function resizeAxisIfNeeded(obj)
            if obj.axisHasNewImage()
                obj.resizeAxisToNewImage();
            end
        end
        function resizeAxisToNewImage(obj)
            obj.resizeAxis();
            obj.updateAxisSize();
            obj.updateZoomIfNeeded();
        end
        function resizeAxis(obj)
            ax = obj.getAxis();
            [height, width] = obj.getImageSize();
            resizeAxis(ax, height, width);
        end
        function updateAxisSize(obj)
            [height, width] = obj.getImageSize();
            obj.setAxisSize(height, width);
        end
        function setAxisSize(obj, height, width)
            obj.axisHeight = height;
            obj.axisWidth = width;
        end
        function updateZoomIfNeeded(obj)
            if obj.zoomIsEnabled()
                obj.updateOriginalLims(); % update zoomer for new image
            end
        end

        function thresholdSliderChanging(obj, ~, event)
            obj.intensityThresholds = event.Value;
            obj.updateFromRawImage();
        end
        function updateFromRawImage(obj)
            im = obj.getPreprocessedImage();
            obj.showImage(im);
        end
        function im = getPreprocessedImage(obj)
            im = obj.getRawImage();
            if obj.imageExists()
                im = obj.preprocessImage(im);
            end
        end
        function im = preprocessImage(obj, im)
            preprocessor = obj.getPreprocessor();
            im = preprocessor(im);
        end
    
        function invertCheckboxChanged(obj, ~, ~)
            obj.updateFromRawImage();
        end
    end

    methods (Access = private)
        function setRawImage(obj, im)
            obj.rawImage = im;
        end
        function setImageCData(obj, cData)
            set(obj.getInteractiveImage(), "CData", cData);
        end
        function iIm = getInteractiveImage(obj)
            iIm = obj.interactiveImage;
        end
        function im = getRawImage(obj)
            im = obj.rawImage;
        end
        function im = getImageCData(obj)
            im = get(obj.getInteractiveImage(), "CData");
        end

        function is = zoomIsEnabled(obj)
            is = obj.doZoom;
        end
        function width = getFullAxisWidth(obj)
            width = obj.axisWidth;
        end
        function width = getFullAxisHeight(obj)
            width = obj.axisHeight;
        end
        function [height, width] = getImageSize(obj)
            im = obj.getImageCData();
            [height, width, ~] = size(im);
        end

        function is = isNewHeight(obj, height)
            fullHeight = obj.getFullAxisHeight();
            is = fullHeight ~= height;
        end
        function is = isNewWidth(obj, width)
            fullWidth = obj.getFullAxisWidth();
            is = fullWidth ~= width;
        end
        function is = isNewSize(obj, height, width)
            is = obj.isNewWidth(width) || obj.isNewHeight(height);
        end
        function is = axisHasNewImage(obj)
            [height, width] = obj.getImageSize();
            is = obj.isNewSize(height, width);
        end
    end

    methods
        % ...for preprocessing
        function processor = getPreprocessor(obj)
            thresholds = obj.getThresholds();
            invert = obj.getInvert();
            processor = Preprocessor(thresholds, invert);
            processor = @processor.preprocess;
        end
        function vals = getThresholds(obj)
            vals = obj.intensityThresholds;
        end
        function invert = getInvert(obj)
            invert = obj.invertCheckbox.Value;
        end
    end

    methods (Access = private)
        function fig = getFigure(obj)
            ax = obj.getAxis();
            fig = ancestor(ax, "figure");
        end

        % threshold slider and invert checkbox
        function elem = getThresholdSlider(obj)
            elem = obj.thresholdSlider;
        end
        function elem = getInvertCheckbox(obj)
            elem = obj.invertCheckbox;
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

%% Function to generate intensity bound input
% Generates two-value slider allowing user to set lower and upper bounds on
% image intensity
%
% Arguments
%
% * uigridlayout |gl|: layout to add slider in
%
% Returns uislider
function slider = generateThresholdSlider(gl)
slider = uislider(gl, "range");

% set major and minor tick locations
maxIntensity = 2^16; % maximum intensity for TIF image
slider.Limits = [0 maxIntensity];
slider.Value = [0 maxIntensity];
slider.MinorTicks = 0:2^11:maxIntensity;
slider.MajorTicks = 0:2^14:maxIntensity;

% format major tick labels
majorTicks = slider.MajorTicks;
tickCount = numel(majorTicks);
majorTickLabels = strings(1, tickCount);
for index = 1:tickCount
    majorTick = majorTicks(index);
    majorTickLabels(index) = sprintf("%d", majorTick);
end
slider.MajorTickLabels = majorTickLabels;
end

%% Function to generate invert checkbox
% Generates checkbox allowing user to invert image by intensity
%
% Arguments
%
% * uigridlayout |gl|: layout to add checkbox in
%
% Returns uicheckbox
function checkbox = generateInvertCheckbox(gl)
checkbox = uicheckbox(gl);
checkbox.Text = "Invert";
end

%% Function to generate plotting axis
% Generates axis on which hair cell image is plotted
%
% Arguments
%
% * uigridlayout |gl|: layout to add axis in
%
% Returns uiaxes
function ax = generateAxis(gl)
ax = uiaxes(gl);
ax.Visible = "off";
ax.Toolbar.Visible = "off";
end

%% Function to generate interactive image on axis
% Generates empty image and plots onto |ax|.
% Set CData property to change image displayed on axis
%
% Arguments
%
% * uiaxes |ax|: layout to add image in
%
% Returns Image
function im = generateImage(ax)
fig = ancestor(ax, "figure");
im = image(ax, gray2rgb([], fig)); % display RGB image
end


function is = isLeftClick(mouseButton)
is = mouseButton == 1;
end

function resizeAxis(ax, height, width)
if width > 0 && height > 0
    if width <= 2 * height && height <= 2 * width
        set(ax, ...
            "XLim", [0, width], ...
            "YLim", [0, height] ...
            );
        pbaspect(ax, [width, height, 1]);
    elseif width > 2 * height
        set(ax, ...
            "XLim", [0, width], ...
            "YLim", width * [-0.5, 0.5] ...
            );
        pbaspect(ax, [1 1 1]);
    elseif height > 2 * width
        set(ax, ...
            "XLim", height * [-0.5, 0.5], ...
            "YLim", [0, height] ...
            );
        pbaspect(ax, [1 1 1]);
    end
end
end
function saveImageOnAxis(ax, extensions, startDirectory)
[filename, directoryPath, ~] = uiputfile( ...
    extensions, "Save Image", startDirectory ...
    );

if isfolder(directoryPath)
    filepath = strcat(directoryPath, filename);
    exportgraphics(ax, filepath);
end
end
function rect = drawRectangle(ax, point)
rect = images.roi.Rectangle(ax);
beginDrawingFromPoint(rect, point);
end
function rects = getRegionsFromAxis(ax)
children = ax.Children;
rects = findobj(children, "Type", "images.roi.rectangle");
end

function maskRgb = createMaskRgb(regions)
mask = createMasks(regions);
maskRgb = repmat(mask, [1 1 3]);
end
function masks = createMasks(regions)
masks = createMask(regions(1));
regionCount = numel(regions);
for index = 2:regionCount
    region = regions(index);
    mask = createMask(region);
    masks(mask) = 1;
end
end
function rgb = gray2rgb(im, fig)
cmap = colormap(fig, "turbo");
cmap(1, :) = 0; % set dark pixels as black
cmap(end, :) = 1; % set saturated pixels as white
rgb = ind2rgb(im2uint8(im), cmap);
end