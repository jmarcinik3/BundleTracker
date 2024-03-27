classdef BlobDetectorLinker < handle
    properties (Access = private)
        gui;
        imPreprocessed;
        blobAnalyzer;
        applyRegions = false;

        blobShape;
        rectanglePositions;
        ellipseParameters;

        blobAreas;
        blobCenters;
        blobBoundingBoxes;
        blobMajorAxes;
        blobMinorAxes;
        blobAngles;
    end

    methods
        function obj = BlobDetectorLinker(gui, im)
            ax = gui.getAxis();
            fig = gui.getFigure();
            iIm = image(ax, gray2rgb(mat2gray(im), fig)); % display RGB image
            AxisResizer(iIm, "FitToContent", true);

            blobShapeDropdown = gui.getShapeDropdown();
            set(gui.getThresholdSlider(), "ValueChangingFcn", @obj.thresholdsChanging);
            set(gui.getAreaSlider(), "ValueChangingFcn", @obj.blobAreaChanging );
            set(gui.getConnectivityElement(), "ValueChangedFcn", @obj.connectivityChanged);
            set(gui.getCountSpinner(), "ValueChangingFcn", @obj.maximumCountChanging);
            set(blobShapeDropdown, "ValueChangedFcn", @obj.blobShapeChanged);
            set(gui.getSizeSpinners(), "ValueChangingFcn", @obj.blobSizeChanging);
            set(gui.getExcludeBorderBlobsCheckbox(), "ValueChangedFcn", @obj.excludeBorderBlobsChanged);
            set(gui.getActionButtons(), "ButtonPushedFcn", @obj.actionButtonPushed);

            obj.gui = gui;
            obj.blobShape = get(blobShapeDropdown, "Value");
            obj.blobAnalyzer = generateBlobAnalyzer(gui);
            obj.imPreprocessed = detrendMatrix(im);
            obj.redetectBlobs();
        end
    end

    %% Functions to generate regions
    methods (Static)
        function [parameters, blobShape] = openFigure(im)
            fig = uifigure;
            colormap(fig, "turbo");
            gui = BlobDetectorGui(fig);
            linker = BlobDetectorLinker(gui, im);
            uiwait(fig);

            blobShape = linker.blobShape;
            parameters = linker.getBlobParameters();
        end
    end

    %% Functions to retrieve state information
    methods (Access = private)
        function parameters = getBlobParameters(obj)
            switch obj.blobShape
                case BlobDrawer.ellipseKeyword
                    parameters = obj.getEllipseParameters();
                case BlobDrawer.rectangleKeyword
                    parameters = obj.getRectanglePositions();
            end
        end
        function rectPositions = getRectanglePositions(obj)
            rectPositions = [];
            if obj.applyRegions
                rectPositions = obj.rectanglePositions;
            end
        end
        function ellipseParameters = getEllipseParameters(obj)
            ellipseParameters = [];
            if obj.applyRegions
                ellipseParameters = obj.ellipseParameters;
            end
        end
    end
    methods (Access = private)
        function im = generateThresholdedImage(obj, thresholds)
            if nargin == 1
                thresholds = obj.gui.getThresholds();
            end
            im = obj.imPreprocessed;
            im = im > thresholds(1) & im < thresholds(2);
        end

        function parameters = generateBlobParameters(obj, h, w)
            switch obj.blobShape
                case BlobDrawer.ellipseKeyword
                    parameters = obj.generateEllipseParameters(h, w);
                case BlobDrawer.rectangleKeyword
                    parameters = obj.generateRectanglePositions(h, w);
            end
        end
        function rectPositions = generateRectanglePositions(obj, h, w)
            blobCenters = obj.blobCenters;
            rectPositions = generateRectanglePositions(blobCenters, [w, h]);
            obj.rectanglePositions = rectPositions;
        end
        function ellipseParameters = generateEllipseParameters(obj, h, w)
            blobCenters = obj.blobCenters;
            ellipseAngles = obj.blobAngles;
            ellipseParameters = generateEllipseParameters(blobCenters, [w, h], ellipseAngles);
            obj.ellipseParameters = ellipseParameters;
        end
    end

    %% Functions to update state of GUI
    methods (Access = private)
        function setBlobAnalyzer(obj, varargin)
            blobAnalyzer = obj.blobAnalyzer;
            release(blobAnalyzer);
            set(blobAnalyzer, varargin{:});
            obj.redetectBlobs();
        end
        function redetectBlobs(obj, thresholds)
            gui = obj.gui;
            if nargin == 1
                thresholds = gui.getThresholds();
            end

            obj.updateBlobParameters(thresholds);
            [h, w] = gui.getRectangleSize();
            obj.redrawBlobs(h, w);
        end
        function updateBlobParameters(obj, thresholds)
            if nargin == 1
                thresholds = obj.gui.getThresholds();
            end

            blobAnalyzer = obj.blobAnalyzer;
            im = obj.generateThresholdedImage(thresholds);

            [area, center, bbox, majAx, minAx, angle] = step(blobAnalyzer, im);
            obj.blobAreas = area;
            obj.blobCenters = center;
            obj.blobBoundingBoxes = bbox;
            obj.blobMajorAxes = majAx;
            obj.blobMinorAxes = minAx;
            obj.blobAngles = angle;
        end
        function redrawBlobs(obj, h, w)
            gui = obj.gui;
            ax = gui.getAxis();

            blobShape = gui.getBlobShape();
            blobParameters = obj.generateBlobParameters(h, w);
            BlobDrawer.byKeyword(ax, blobParameters, blobShape);
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
            obj.setBlobAnalyzer( ...
                "MinimumBlobArea", areas(1), ...
                "MaximumBlobArea", areas(2) ...
                );
        end
        function connectivityChanged(obj, ~, event)
            connectivity = event.Value;
            obj.setBlobAnalyzer("Connectivity", connectivity);
        end
        function maximumCountChanging(obj, ~, event)
            maxCount = event.Value;
            obj.setBlobAnalyzer("MaximumCount", maxCount);
        end
        function excludeBorderBlobsChanged(obj, ~, event)
            excludeBorderBlobs = event.Value;
            obj.setBlobAnalyzer("ExcludeBorderBlobs", excludeBorderBlobs);
        end

        function blobShapeChanged(obj, ~, event)
            obj.blobShape = event.Value;
            gui = obj.gui;
            h = gui.getBlobHeight();
            w = gui.getBlobWidth();
            obj.redrawBlobs(h, w);
        end
        function blobSizeChanging(obj, source, event)
            gui = obj.gui;
            if source == gui.getHeightSpinner()
                h = event.Value;
                w = gui.getBlobWidth();
            elseif source == gui.getWidthSpinner()
                w = event.Value;
                h = gui.getBlobHeight();
            end
            obj.redrawBlobs(h, w);
        end
    end
end



function blobAnalyzer = generateBlobAnalyzer(gui)
areas = gui.getAreas();
connectivity = gui.getConnectivity();
maxCount = gui.getMaximumCount();
excludeBorderBlobs = gui.getExcludeBorderBlob();

blobAnalyzer = vision.BlobAnalysis( ...
    "AreaOutputPort", true, ...
    "CentroidOutputPort", true, ...
    "BoundingBoxOutputPort", true, ...
    "MajorAxisLengthOutputPort", true, ...
    "MinorAxisLengthOutputPort", true, ...
    "OrientationOutputPort", true, ...
    "MinimumBlobArea", areas(1), ...
    "MaximumBlobArea", areas(2), ...
    "Connectivity", connectivity, ...
    "MaximumCount", maxCount, ...
    "ExcludeBorderBlobs", excludeBorderBlobs ...
    );
end

function rectPositions = generateRectanglePositions(rectCenters, rectSize)
rectCount = size(rectCenters, 1);
rectLengths = repmat(rectSize, [rectCount, 1]);
rectCorners = rectCenters - 0.5 * rectLengths;
rectPositions = [rectCorners, rectLengths];
end

function parameters = generateEllipseParameters(centers, sizes, angles)
ellipseCount = size(centers, 1);
lengths = repmat(0.5 * sizes, [ellipseCount, 1]);
parameters = [centers, lengths, angles];
end

function imPreprocessed = detrendMatrix(im)
imPreprocessed = double(im);
imPreprocessed = imPreprocessed - smoothdata2(imPreprocessed, "movmean");
imPreprocessed = mat2gray(imPreprocessed);
end
