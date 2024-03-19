classdef AutoThresholdLinker < handle
    properties (Access = private)
        gui;
        regionalImages;
        interactiveImages;
        regionThresholds;
        applyThresholds = false;
    end

    methods
        function obj = AutoThresholdLinker(gui, im, regions)
            axs = gui.getAxes();
            [regionalImages, iIms] = generateInteractiveImages(regions, axs, im);

            regionCount = numel(regions);
            obj.regionThresholds = preallocateRegionThresholds(regionCount);
            obj.interactiveImages = iIms;
            obj.regionalImages = regionalImages;

            levelSlider = gui.getLevelSlider();
            set(levelSlider, "ValueChangingFcn", @obj.levelChanging);
            set(gui.getActionButtons(), "ButtonPushedFcn", @obj.actionButtonPushed);

            obj.gui = gui;
            obj.levelChanged(levelSlider.Value);
        end
    end

    %% Functions to generate thresholds
    methods (Static)
        function regionsThreshold = openFigure(im, regions)
            regionCount = numel(regions);

            fig = uifigure;
            colormap(fig, "turbo");
            gui = AutoThresholdGui(fig, regionCount);
            linker = AutoThresholdLinker(gui, im, regions);
            uiwait(fig);

            regionsThreshold = linker.getCurrentThresholds();
        end
    end

    %% Functions to retrive state information
    methods
        function regionsThreshold = getCurrentThresholds(obj)
            if obj.applyThresholds
                regionCount = obj.getRegionCount();
                regionsThreshold = arrayfun(@obj.getCurrentThreshold, 1:regionCount);
            else
                regionsThreshold = [];
            end
        end
        function regionThreshold = getCurrentThreshold(obj, index)
            levelThreshold = levels(1);
            levelCount = levels(2);

            regionThresholds = obj.getRegionThresholds(index, levelCount);
            regionThreshold = interpolateThreshold(levelThreshold, regionThresholds);
        end
    end


    methods (Access = private)
        function regionCount = getRegionCount(obj)
            regionCount = numel(obj.interactiveImages);
        end
        function im = getRegionalImage(obj, index)
            im = obj.regionalImages{index};
        end
        function thresholds = getRegionThresholds(obj, index, levelCount)
            thresholds = obj.regionThresholds(index, levelCount, 1:levelCount);
            thresholds = squeeze(thresholds);
        end

        function thresholds = generateThresholds(obj, regionIndex, levelCount)
            if levelCount == 0
                thresholds = 0;
            elseif obj.thresholdsExist(regionIndex, levelCount)
                
                thresholds = obj.getRegionThresholds(regionIndex, levelCount);
                
            else
                im = obj.getRegionalImage(regionIndex);
                thresholds = generateThresholds(im, levelCount);
                obj.setRegionThresholds(regionIndex, levelCount, thresholds);
            end
        end
        function is = thresholdsExist(obj, index, levelCount)
            minRegionThresholds = obj.regionThresholds(index, levelCount, 1);
            is = minRegionThresholds > 0;
        end
    end

    %% Functions to set state information
    methods (Access = private)
        function setRegionThresholds(obj, index, levelCount, thresholds)
            obj.regionThresholds(index, levelCount, 1:levelCount) = thresholds;
        end
    end

    %% Functions to update state of GUI
    methods (Access = private)
        function levelChanging(obj, ~, event)
            levels = levelsFromEvent(event);
            obj.levelChanged(levels);
        end
        function levelChanged(obj, levels)
            regionCount = obj.getRegionCount();
            for index = 1:regionCount
                obj.rethresholdRegion(index, levels);
            end
        end

        function rethresholdRegion(obj, index, levels)
            im = obj.regionalImages{index};
            levelThreshold = levels(1);
            levelCount = levels(2);
            thresholds = obj.generateThresholds(index, levelCount);
            im = thresholdMatrix(im, thresholds, levelThreshold);
            obj.displayRegionalImage(index, im);
        end
        function displayRegionalImage(obj, index, im)
            fig = obj.gui.getFigure();
            iIm = obj.interactiveImages(index);
            im = gray2rgb(im, fig);
            set(iIm, "CData", im);
        end

        function actionButtonPushed(obj, source, ~)
            gui = obj.gui;
            fig = gui.getFigure();
            obj.applyThresholds = source == gui.getApplyButton();
            close(fig);
        end
    end
end



function [regionalImages, iIms] = generateInteractiveImages(regions, axs, im)
iIms = [];
regionalImages = {};
regionCount = numel(regions);

for index = regionCount:-1:1
    region = regions(index);
    ax = axs(index);
    [regionalImage, iIm] = generateRegionalInteractiveImage(region, ax, im);
    regionalImages{index} = regionalImage;
    iIms(index) = iIm;
end
end

function [regionalImage, iIm] = generateRegionalInteractiveImage(region, ax, im)
regionalImage = generateRegionalImage(region, im);
iIm = generateInteractiveImage(ax, regionalImage);
end
function regionalImage = generateRegionalImage(region, im)
regionalImage = MatrixUnpadder.byRegion2d(region, im);
end
function iIm = generateInteractiveImage(ax, im)
fig = ancestor(ax, "figure");
iIm = image(ax, gray2rgb(im, fig));
AxisResizer(iIm, "FitToContent", true, "AddListener", false);
end

function matrix = preallocateRegionThresholds(regionCount)
maxLevelCount = AutoThresholdGui.maxLevelCount;
matrix = zeros(regionCount, maxLevelCount, maxLevelCount);
end

function levels = levelsFromEvent(event)
levels = event.Value;
levels(2) = ceil(levels(2));
end

function thresholds = generateThresholds(im, levelCount)
thresholds = multithresh(im, levelCount);
end

function im = thresholdMatrix(im, thresholds, levelThreshold)
threshold = getThresholdFromLevel(levelThreshold, thresholds);
noiseRemover = NoiseRemover(threshold, Inf);
im = noiseRemover.get(im);
end

function threshold = getThresholdFromLevel(level, thresholds)
threshold = uint16(twoValueInterpolate(double(thresholds), level, 0));
end
