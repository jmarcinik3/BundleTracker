classdef AutoThresholdsLinker < AutoThresholdLinker
    methods
        function obj = AutoThresholdsLinker(gui, regionalImages, thresholdFcn)
            obj@AutoThresholdLinker(gui, regionalImages, thresholdFcn);

            levelsSlider = gui.getLevelsSlider();
            set(levelsSlider, "ValueChangingFcn", @obj.levelsChanging);
            set(gui.getActionButtons(), "ButtonPushedFcn", @obj.actionButtonPushed);
            set(gui.getCountSpinner(), "ValueChangingFcn", @obj.countSpinnerChanging);
            
            maxLevelCount = gui.getMaxLevelCount();
            initialLevels = get(levelsSlider, "Value");
            rerangeLevelsSlider(levelsSlider, maxLevelCount);
            obj.changeLevels(initialLevels);
        end
    end

    %% Functions to update state of GUI
    methods (Access = private)
        function levelsChanging(obj, ~, event)
            levels = event.Value;
            obj.changeLevels(levels);
        end
        function changeLevels(obj, levels, levelCount)
            if nargin == 2
                gui = obj.getGui();
                levelCount = gui.getLevelCount();
            end

            regionCount = obj.getRegionCount();
            for index = 1:regionCount
                im = obj.rethresholdRegion(index, levels, levelCount);
                obj.displayRegionalImage(index, im);
            end
        end

        function countSpinnerChanging(obj, ~, event)
            levelCount = event.Value;
            obj.rerangeLevelsSlider(levelCount);
        end
        function rerangeLevelsSlider(obj, levelCount)
            gui = obj.getGui();
            levelsSlider = gui.getLevelsSlider();
            newLevels = rerangeLevelsSlider(levelsSlider, levelCount);
            obj.changeLevels(newLevels, levelCount);
        end
    end
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
