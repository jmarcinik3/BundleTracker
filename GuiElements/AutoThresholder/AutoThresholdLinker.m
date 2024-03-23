classdef AutoThresholdLinker < AutoThresholder
    properties (Access = protected)
        thresholdRanges = [];
    end

    properties (Access = private)
        gui;
        interactiveImages;
        applyThresholds = false;
    end

    methods
        function obj = AutoThresholdLinker(gui, regionalImages, thresholdFcn, maxLevelCount)
            if nargin == 3
                maxLevelCount = 1;
            end

            obj@AutoThresholder(regionalImages, thresholdFcn, maxLevelCount);

            axs = gui.getAxes();
            iIms = generateInteractiveImages(axs, regionalImages);
            set(gui.getActionButtons(), "ButtonPushedFcn", @obj.actionButtonPushed);

            obj.gui = gui;
            obj.interactiveImages = iIms;

            regionCount = numel(regionalImages);
            for index = 1:regionCount
                im = obj.rethresholdRegion(index, [1, 2], 1);
                obj.displayRegionalImage(index, im);
            end
        end
    end

    %% Functions to open GUI
    methods (Static)
        function thresholdRanges = openGui(fig, regionalImages, thresholdFcn)
            regionCount = numel(regionalImages);
            gui = AutoThresholdGui(fig, regionCount);
            linker = AutoThresholdLinker(gui, regionalImages, thresholdFcn);
            uiwait(fig);
            thresholdRanges = linker.thresholdRanges;
        end
    end

    %% Functions to retrieve GUI elements
    methods (Access = protected)
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
            fig = obj.gui.getFigure();
            iIm = obj.interactiveImages(index);
            im = gray2rgb(im, fig);
            set(iIm, "CData", im);
        end

        function actionButtonPushed(obj, source, ~)
            gui = obj.gui;
            fig = gui.getFigure();
            obj.applyThresholds = source == gui.getApplyButton();
            obj.thresholdRanges = obj.getCurrentThresholds();
            close(fig);
        end
    end
end



function iIms = generateInteractiveImages(axs, regionalImages)
iIms = [];
regionCount = numel(regionalImages);

for index = regionCount:-1:1
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
if obj.isSingleThreshold
    levels = [1, 2];
    levelCount = 1;
else
    gui = obj.gui;
    levels = gui.getLevels();
    levelCount = gui.getLevelCount();
end
end
