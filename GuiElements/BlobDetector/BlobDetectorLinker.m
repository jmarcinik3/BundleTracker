classdef BlobDetectorLinker < handle
    properties (Access = private)
        gui;
        imPreprocessed;
        blobAnalyzer;
        blobCenters;
        rectanglePositions;
        applyRegions = false;
    end

    methods
        function obj = BlobDetectorLinker(gui, im)
            ax = gui.getAxis();
            fig = gui.getFigure();
            iIm = image(ax, gray2rgb(mat2gray(im), fig)); % display RGB image
            AxisResizer(iIm, "FitToContent", true);

            set(gui.getThresholdSlider(), "ValueChangingFcn", @obj.thresholdsChanging);
            set(gui.getAreaSlider(), "ValueChangingFcn", @obj.blobAreaChanging );
            set(gui.getConnectivityElement(), "ValueChangedFcn", @obj.connectivityChanged);
            set(gui.getCountSpinner(), "ValueChangingFcn", @obj.maximumCountChanging);
            set(gui.getSizeSpinners(), "ValueChangingFcn", @obj.rectangleSizeChanging);
            set(gui.getActionButtons(), "ButtonPushedFcn", @obj.actionButtonPushed);

            obj.gui = gui;
            obj.blobAnalyzer = generateBlobAnalyzer(gui);
            obj.imPreprocessed = detrendMatrix(im);
            obj.redetectBlobs();
        end
    end

    %% Functions to generate regions
    methods (Static)
        function rectanglePositions = openFigure(im)
            fig = uifigure;
            colormap(fig, "turbo");
            gui = BlobDetectorGui(fig);
            linker = BlobDetectorLinker(gui, im);
            uiwait(fig);

            rectanglePositions = linker.getRectanglePositions();
        end
    end

    %% Functions to retrieve state information
    methods
        function rectPositions = getRectanglePositions(obj)
            if obj.applyRegions
                rectPositions = obj.rectanglePositions;
            else
                rectPositions = [];
            end
        end
    end
    methods (Access = private)
        function rects = getRectangles(obj)
            ax = obj.gui.getAxis();
            rects = findobj(ax.Children, "Type", "rectangle");
        end
        function im = generateThresholdedImage(obj, thresholds)
            if nargin == 1
                thresholds = obj.gui.getThresholds();
            end
            im = obj.imPreprocessed;
            im = im > thresholds(1) & im < thresholds(2);
        end
        function rectPositions = generateRectanglePositions(obj, h, w)
            blobCenters = obj.blobCenters;
            rectPositions = generateRectanglePositions(blobCenters, [w, h]);
            obj.rectanglePositions = rectPositions;
        end
    end

    %% Functions to update state of GUI
    methods (Access = private)
        function redetectBlobs(obj, thresholds)
            gui = obj.gui;
            if nargin == 1
                thresholds = gui.getThresholds();
            end

            obj.updateBlobCenters(thresholds);
            [h, w] = gui.getRectangleSize();
            obj.redrawRectangles(h, w);
        end
        function updateBlobCenters(obj, thresholds)
            if nargin == 1
                thresholds = obj.gui.getThresholds();
            end
            blobAnalyzer = obj.blobAnalyzer;
            im = obj.generateThresholdedImage(thresholds);
            obj.blobCenters = step(blobAnalyzer, im);
        end
        function redrawRectangles(obj, h, w)
            ax = obj.gui.getAxis();
            rectPositions = obj.generateRectanglePositions(h, w);
            redrawRectangles(ax, rectPositions);
        end

        function actionButtonPushed(obj, source, ~)
            gui = obj.gui;
            fig = gui.getFigure();
            obj.applyRegions = source == gui.getApplyButton();
            close(fig);
        end
        function thresholdsChanging(obj, ~, event)
            thresholds = event.Value;
            obj.redetectBlobs(thresholds);
        end
        function blobAreaChanging(obj, ~, event)
            areas = uint16(event.Value);
            blobAnalyzer = obj.blobAnalyzer;
            release(blobAnalyzer);
            set(blobAnalyzer, ...
                "MinimumBlobArea", areas(1), ...
                "MaximumBlobArea", areas(2) ...
                );
            obj.redetectBlobs();
        end
        function connectivityChanged(obj, ~, event)
            connectivity = event.Value;
            blobAnalyzer = obj.blobAnalyzer;

            release(blobAnalyzer);
            set(blobAnalyzer, "Connectivity", connectivity);
            obj.redetectBlobs();
        end
        function maximumCountChanging(obj, ~, event)
            maxCount = event.Value;
            blobAnalyzer = obj.blobAnalyzer;

            release(blobAnalyzer);
            set(blobAnalyzer, "MaximumCount", maxCount);
            obj.redetectBlobs();
        end
        function rectangleSizeChanging(obj, source, event)
            gui = obj.gui;
            if source == gui.getHeightSpinner()
                h = event.Value;
                w = gui.getRectangleWidth();
            elseif source == gui.getWidthSpinner()
                w = event.Value;
                h = gui.getRectangleHeight();
            end
            obj.redrawRectangles(h, w);
        end
    end
end



function blobAnalyzer = generateBlobAnalyzer(gui)
areas = gui.getAreas();
connectivity = gui.getConnectivity();
maxCount = gui.getMaximumCount();
blobAnalyzer = vision.BlobAnalysis( ...
    "AreaOutputPort", false, ...
    "BoundingBoxOutputPort", false, ...
    "MinimumBlobArea", areas(1), ...
    "MaximumBlobArea", areas(2), ...
    "Connectivity", connectivity, ...
    "MaximumCount", maxCount ...
    );
end

function rectPositions = generateRectanglePositions(blobCenters, rectSize)
blobCount = size(blobCenters, 1);
rectLengths = repmat(rectSize, [blobCount, 1]);
rectCorners = blobCenters - 0.5 * rectLengths;
rectPositions = [rectCorners, rectLengths];
end

function redrawRectangles(ax, positions)
rects = findobj(ax.Children, "Type", "rectangle");
delete(rects);

rectCount = size(positions, 1);
for blobIndex = 1:rectCount
    position = positions(blobIndex, :);
    drawRectangle(ax, position);
end
end

function rect = drawRectangle(ax, position)
rect = rectangle(ax, ...
    "Position", position, ...
    "EdgeColor", "black", ...
    "LineWidth", 2 ...
    );
end

function imPreprocessed = detrendMatrix(im)
imPreprocessed = double(im);
imPreprocessed = imPreprocessed - smoothdata2(imPreprocessed, "movmean");
imPreprocessed = mat2gray(imPreprocessed);
end

function rgb = gray2rgb(im, fig)
cmap = colormap(fig);
cmap(1, :) = 0; % set dark pixels as black
cmap(end, :) = 1; % set saturated pixels as white
rgb = ind2rgb(im2uint8(im), cmap);
end
