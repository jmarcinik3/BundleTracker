classdef AutoThresholderLinker < AutoThresholdLinker
    methods
        function obj = AutoThresholderLinker(gui, regionalImages)
            obj@AutoThresholdLinker(gui, regionalImages);

            levelsSlider = gui.getLevelsSlider();
            maxLevelCount = gui.getMaxLevelCount();

            set(gui.getCountSpinner(), "ValueChangingFcn", @obj.countSpinnerChanging);
            rerangeLevelsSlider(levelsSlider, maxLevelCount);
        end
    end

    %% Functions to update state of GUI
    methods (Access = private)
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
majorTickInterval = 1; % ceil(sqrt(newMax));

set(slider, ...
    "Limits", newLimits, ...
    "Value", newLevels, ...
    "MinorTicks", 0:1:newMax, ...
    "MajorTicks", 0:majorTickInterval:newMax ...
    );
end
