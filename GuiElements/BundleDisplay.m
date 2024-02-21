classdef BundleDisplay < PanZoomer
    properties (Access = private)
        %#ok<*PROP>
        %#ok<*PROPLC>

        axis; % uiaxes on which image is plotted
        im = [];  % image object containing pixel data and drawn regions

        doZoom;
        axisWidth = 0;
        axisHeight = 0;
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
        function obj = BundleDisplay(gl, varargin)
            p = inputParser;
            addOptional(p, "EnableZoom", true);
            parse(p, varargin{:});
            enableZoom = p.Results.EnableZoom;

            ax = generateAxis(gl);
            obj@PanZoomer(ax);
            obj.axis = ax;

            obj.generateInteractiveImage(ax);
            obj.doZoom = enableZoom;
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
        function obj = update(obj, im)
            % Updates displayed image given 2D matrix of pixel intensities
            obj.show(im); % plot 2D matrix on stored axes
            obj.resize(); % resize axes to image size for proper aspect ratio
        end
        function save(obj, startDirectory)
            % Saves currently displayed bundle image and drawn regions
            extensions = BundleDisplay.imageExtensions;
            ax = obj.getAxis();
            saveImageOnAxis(ax, extensions, startDirectory);
        end
        
        function ax = getAxis(obj)
            % Retrieves uiaxes on which image is plotted
            ax = obj.axis;
        end
    end

    methods (Access = private)
        function generateInteractiveImage(obj, ax)
            im = generateImage(ax);
            im.ButtonDownFcn = @obj.buttonDownFcn; % draw rectangles on image
            obj.im = im;
        end
    end

    methods (Access = private)
        function buttonDownFcn(obj, source, event)
            mouseButton = event.Button;
            if mouseButton == 1 % left click
                obj.draw(source, event);
            end
        end
        function draw(obj, ~, event)
            point = event.IntersectionPoint(1:2);
            ax = obj.getAxis();
            color = obj.unprocessedColor;
            regions = obj.getRegions();

            count = numel(regions);
            label = num2str(count + 1);
            drawRectangle(ax, point, color, label);
        end

        function show(obj, im)
            ax = obj.getAxis();
            fig = ancestor(ax, "figure");
            imRgb = gray2rgb(im, fig);
            set(obj.im, "CData", imRgb);
        end
        function resize(obj)
            ax = obj.getAxis();
            [height, width] = obj.getImageSize();

            if obj.isNewWidth(width) || obj.isNewHeight(height)
                resizeAxis(ax, width, height);
                if obj.doZoom
                    obj.updateOriginalLims(); % update zoomer for new image
                end

                obj.axisWidth = width;
                obj.axisHeight = height;
            end
        end
    end

    methods (Access = private)
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
        function im = getImageCData(obj)
            im = obj.im.CData;
        end
        function is = isNewWidth(obj, width)
            fullWidth = obj.getFullAxisWidth();
            is = fullWidth ~= width;
        end
        function is = isNewHeight(obj, height)
            fullHeight = obj.getFullAxisHeight();
            is = fullHeight ~= height;
        end
    end
end



function ax = generateAxis(gl)
ax = uiaxes(gl);
ax.Visible = "off";
ax.Toolbar.Visible = "off";
end

function im = generateImage(ax)
fig = ancestor(ax, "figure");
im = image(ax, gray2rgb([], fig)); % display RGB image
end

function resizeAxis(ax, width, height)
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

function rect = drawRectangle(ax, point, color, label)
rect = images.roi.Rectangle(ax);
beginDrawingFromPoint(rect, point);

rect.Label = label;
rect.Color = color;
addlistener( ...
    rect, "ROIClicked", ...
    @(src, ev) rect.set("Color", color) ...
    );
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