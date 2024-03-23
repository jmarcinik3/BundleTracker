classdef AutoThresholdLinker < AutoThresholder
    properties (Access = private)
        gui;
        interactiveImages;
        regionsThreshold = 0;
        applyThresholds = false;
    end

    methods
        function obj = AutoThresholdLinker(gui, regionalImages)
            obj@AutoThresholder(regionalImages);
            axs = gui.getAxes();
            iIms = generateInteractiveImages(axs, obj.regionalImages);

            levelsSlider = gui.getLevelsSlider();
            set(levelsSlider, "ValueChangingFcn", @obj.levelsChanging);
            set(gui.getActionButtons(), "ButtonPushedFcn", @obj.actionButtonPushed);
            set(gui.getCountSpinner(), "ValueChangingFcn", @obj.countSpinnerChanging);

            obj.gui = gui;
            obj.interactiveImages = iIms;
            
            initialLevels = get(levelsSlider, "Value");
            obj.levelsChanged(initialLevels);
        end
    end

    %% Functions to generate thresholds
    methods (Static)
        function regionsThreshold = openFigure(regionalImages)
            regionCount = numel(regionalImages);

            fig = uifigure;
            colormap(fig, "turbo");
            gui = AutoThresholdGui(fig, regionCount);
            linker = AutoThresholdLinker(gui, regionalImages);
            uiwait(fig);

            regionsThreshold = linker.regionsThreshold;
        end
    end

    %% Functions to retrive state information
    methods (Access = private)
        function regionsThreshold = getCurrentThresholds(obj)
            if obj.applyThresholds
                gui = obj.gui;
                regionCount = obj.getRegionCount();
                levels = gui.getLevels();
                levelCount = gui.getLevelCount();
                regionsThreshold = zeros(regionCount, 2);
                for index = 1:regionCount
                    regionThreshold = obj.generateRegionThreshold(index, levels, levelCount);
                    regionsThreshold(index, :) = regionThreshold;
                end
            else
                regionsThreshold = [];
            end
        end
    end

    %% Functions to update state of GUI
    methods (Access = private)
        function levelsChanging(obj, ~, event)
            levels = event.Value;
            obj.levelsChanged(levels);
        end
        function levelsChanged(obj, levels, levelCount)
            if nargin == 2
                levelCount = obj.gui.getLevelCount();
            end

            regionCount = obj.getRegionCount();
            for index = 1:regionCount
                im = obj.rethresholdRegion(index, levels, levelCount);
                obj.displayRegionalImage(index, im);
            end
        end
        function displayRegionalImage(obj, index, im)
            fig = obj.gui.getFigure();
            iIm = obj.interactiveImages(index);
            im = gray2rgb(im, fig);
            set(iIm, "CData", im);
        end

        function countSpinnerChanging(obj, ~, event)
            levelCount = event.Value;
            obj.rerangeLevelsSlider(levelCount);
        end
        function rerangeLevelsSlider(obj, levelCount)
            levelsSlider = obj.gui.getLevelsSlider();
            newLevels = rerangeLevelsSlider(levelsSlider, levelCount);
            obj.levelsChanged(newLevels, levelCount);
        end

        function actionButtonPushed(obj, source, ~)
            gui = obj.gui;
            fig = gui.getFigure();
            obj.applyThresholds = source == gui.getApplyButton();
            obj.regionsThreshold = obj.getCurrentThresholds();
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

function newLevels = rerangeLevelsSlider(slider, levelCount)
previousLevels = get(slider, "Value");
previousLimits = get(slider, "Limits");
previousLevelCount = previousLimits(2) - 1;

newMax = levelCount + 1;
scaleFactor = newMax / (previousLevelCount + 1);
newLevels = previousLevels * scaleFactor;
newLimits = [0, newMax];
majorTickInterval = ceil(sqrt(newMax));

set(slider, ...
    "Limits", newLimits, ...
    "Value", newLevels, ...
    "MinorTicks", 0:1:newMax, ...
    "MajorTicks", 0:majorTickInterval:newMax ...
    );
end
