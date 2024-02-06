classdef BundleDisplay < handle
    % BundleDisplay Summary of class

    properties
        axis; % uiaxes on which image is plotted
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
    end


    properties (Access = private)
        im = []; %#ok<*PROP> % image object containing pixel data and drawn regions
        unprocessedColor = [0 0.4470 0.7410]; % default rectangle color
    end

    methods
        function obj = BundleDisplay(gl)
            % Generates and stores uiaxes along with image object
            ax = generateAxes(gl); % generate uiaxes
            obj.axis = ax;

            % generate image object
            im = generateImage(ax);
            im.ButtonDownFcn = @obj.draw; % draw rectangles on image
            obj.im = im;
        end

        function clearRegions(obj)
            % Removes currently drawn regions on image
            regions = obj.getRegions();
            delete(regions);
        end

        function rects = getRegions(obj)
            % Retrieves currently drawn regions on image
            ax =  obj.axis;
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
            ax = obj.axis;
            saveImageOnAxis(ax, extensions, startDirectory);
        end
    end

    methods (Access = private)
        function draw(obj, ~, event)
            point = event.IntersectionPoint(1:2);
            ax = obj.axis;
            color = obj.unprocessedColor;
            regions = obj.getRegions();

            count = numel(regions);
            label = num2str(count + 1);
            drawRectangle(ax, point, color, label);
        end

        function show(obj, im)
            ax = obj.axis;
            fig = ancestor(ax, "figure");
            imRgb = gray2rgb(im, fig);
            set(obj.im, "CData", imRgb);
        end

        function resize(obj)
            ax = obj.axis;
            im = obj.im.CData;
            [width, height, ~] = size(im);
            resizeAxis(ax, width, height);
        end
    end
end



function ax = generateAxes(gl)
ax = uiaxes(gl);
ax.Toolbar.Visible = "off";
ax.Visible = "off";
end

function im = generateImage(ax)
fig = ancestor(ax, "figure");
im = image(ax, gray2rgb([], fig)); % display RGB image
setPointerOnHover(fig, im); % change cursor to cross on hover
end

function setPointerOnHover(fig, im)
pb = struct( ...
    "enterFcn", @(fig, point) set(fig, "Pointer", "cross"), ...
    "exitFcn", [], ...
    "traverseFcn", [] ...
    );

iptSetPointerBehavior(im, pb);
iptPointerManager(fig);
end

function resizeAxis(ax, width, height)
if width > 0 && height > 0
    xlim(ax, [0 height]);
    ylim(ax, [0 width]);
    pbaspect(ax, [height width 1]);
end
end

function saveImageOnAxis(ax, extensions, startDirectory)
[filename, directoryPath, ~] = uiputfile( ...
    extensions, "Save Image", startDirectory ...
    );

if directoryPath ~= 0 % if file dialog canceled
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
disp(rect);
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