classdef AutoThresholdLinker < AutoThresholder
    properties (Access = ?AutoThresholdOpener)
        thresholdRanges = [];
    end

    properties (Access = private)
        gui;
        interactiveImages;
        applyThresholds = false;
    end

    methods
        function obj = AutoThresholdLinker(gui, regionalImages)
            thresholdModeDropdown = gui.getThresholdModeDropdown();
            thresholdKeyword = get(thresholdModeDropdown, "Value");
            thresholdFcn = Threshold.handleByKeyword(thresholdKeyword);
            maxLevelCount = gui.getMaxLevelCount();

            obj@AutoThresholder(regionalImages, thresholdFcn, maxLevelCount);

            axs = gui.getAxes();
            iIms = generateInteractiveImages(axs, regionalImages);
            thresholdModeDropdown = gui.getThresholdModeDropdown();

            set(gui.getLevelsSlider(), "ValueChangingFcn", @obj.levelsChanging);
            set(thresholdModeDropdown, "ValueChangedFcn", @obj.thresholdModeChanged);
            set(gui.getActionButtons(), "ButtonPushedFcn", @obj.actionButtonPushed);

            obj.gui = gui;
            obj.interactiveImages = iIms;

            initialLevels = gui.getLevels();
            thresholdRegions(obj, regionalImages, initialLevels);
        end
    end

    %% Functions to retrieve GUI elements
    methods
        function gui = getGui(obj)
            gui = obj.gui;
        end
    end

    %% Functions to retrive state information
    methods (Access = private)
        function thresholdRanges = getCurrentThresholds(obj)
            if obj.applyThresholds
                [levels, levelCount] = getThresholdsInput(obj);
                regionCount = obj.getRegionCount();
                thresholdRanges = zeros(regionCount, 2);
                for index = 1:regionCount
                    thresholdRange = obj.generateThresholdRange(index, levels, levelCount);
                    thresholdRanges(index, :) = thresholdRange;
                end
            else
                thresholdRanges = [];
            end
        end
    end

    %% Functions to update state of GUI
    methods (Access = protected)
        function displayRegionalImage(obj, index, im)
            gui = obj.getGui();
            fig = gui.getFigure();
            iIm = obj.interactiveImages(index);
            im = gray2rgb(im, fig);
            set(iIm, "CData", im);
        end

        function levelsChanging(obj, ~, event)
            levels = event.Value;
            obj.changeLevels(levels);
        end
        function changeLevels(obj, levels, levelCount)
            gui = obj.getGui();
            if nargin < 2
                levels = gui.getLevels();
            end
            if nargin < 3
                levelCount = gui.getLevelCount();
            end

            regionCount = obj.getRegionCount();
            for index = 1:regionCount
                im = obj.rethresholdRegion(index, levels, levelCount);
                obj.displayRegionalImage(index, im);
            end
        end

        function thresholdModeChanged(obj, ~, event)
            thresholdKeyword = event.Value;
            obj.changeThresholdMode(thresholdKeyword);
        end
        function changeThresholdMode(obj, thresholdMode)
            if nargin < 2
                gui = obj.getGui();
                thresholdMode = gui.getThresholdMode();
            end

            thresholdFcn = Threshold.handleByKeyword(thresholdMode);
            obj.resetRegionsThresholds();
            obj.setThresholdFcn(thresholdFcn);
            obj.changeLevels();
        end

        function actionButtonPushed(obj, source, ~)
            gui = obj.getGui();
            fig = gui.getFigure();
            obj.applyThresholds = source == gui.getApplyButton();
            obj.thresholdRanges = obj.getCurrentThresholds();
            close(fig);
        end
    end
end



function iIms = generateInteractiveImages(axs, regionalImages)
iIms = [];

for index = numel(regionalImages):-1:1
    regionalImage = regionalImages{index};
    ax = axs(index);
    iIm = generateInteractiveImage(ax, regionalImage);
    iIms(index) = iIm;
end
end

function iIm = generateInteractiveImage(ax, im)
fig = ancestor(ax, "figure");
iIm = image(ax, gray2rgb(im, fig));
AxisResizer(iIm, "FitToContent", true, "AddListener", false);
end

function [levels, levelCount] = getThresholdsInput(obj)
gui = obj.getGui();
levels = gui.getLevels();
if obj.isSingleThreshold
    levelCount = 1;
else
    levelCount = gui.getLevelCount();
end
end

function thresholdRegions(obj, regionalImages, levels)
if nargin < 3
    levels = [1, 2];
end

for index = 1:numel(regionalImages)
    im = obj.rethresholdRegion(index, levels, 1);
    obj.displayRegionalImage(index, im);
end
end
