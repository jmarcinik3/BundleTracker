classdef AutoThresholder < handle
    properties (Access = protected)
        regionalImages
    end

    properties (Access = private)
        regionsThresholds;
    end

    methods
        function obj = AutoThresholder(regionalImages)
            regionCount = numel(regionalImages);
            obj.regionalImages = regionalImages;
            obj.regionsThresholds = preallocateRegionThresholds(regionCount);
        end
    end

    %% Functions to retrieve state information
    methods (Access = protected)
        function regionCount = getRegionCount(obj)
            regionCount = numel(obj.regionalImages);
        end
        function im = getRegionalImage(obj, index)
            im = obj.regionalImages{index};
        end
        function thresholds = getRegionThresholds(obj, index, levelCount)
            thresholds = obj.regionsThresholds(index, levelCount, :);
            thresholds = squeeze(thresholds);
        end

        function thresholds = generateThresholds(obj, regionIndex, levelCount)
            if levelCount == 0
                thresholds = 0;
            elseif obj.thresholdsExist(regionIndex, levelCount)
                thresholds = obj.getRegionThresholds(regionIndex, levelCount);
            else
                im = obj.getRegionalImage(regionIndex);
                thresholds = [0, multithresh(im, levelCount), Inf];
                obj.setRegionThresholds(regionIndex, levelCount, thresholds);
            end
        end
        function is = thresholdsExist(obj, index, levelCount)
            minRegionThresholds = obj.regionsThresholds(index, levelCount, 2);
            is = minRegionThresholds > 0;
        end
    end

    %% Functions to set state information
    methods (Access = protected)
        function setRegionThresholds(obj, index, levelCount, thresholds)
            obj.regionsThresholds(index, levelCount, 1:levelCount+2) = thresholds;
        end
    end

    %% Functions to update state of GUI
    methods (Access = protected)
        function im = rethresholdRegion(obj, index, levels, levelCount)
            im = obj.regionalImages{index};
            thresholdRange = obj.generateRegionThreshold(index, levels, levelCount);
            noiseRemover = NoiseRemover(thresholdRange);
            im = noiseRemover.get(im);
        end
        function thresholdRange = generateRegionThreshold(obj, index, levels, levelCount)
            thresholds = obj.generateThresholds(index, levelCount);
            thresholdRange = getThresholdsFromLevels(levels, thresholds);
        end
    end
end



function matrix = preallocateRegionThresholds(regionCount)
maxLevelCount = AutoThresholdGui.maxLevelCount;
% (number of regions; max number of levels; threshold levels < max number)
% +2 for threshold=0->0 and threshold=max_number+1->Inf; used to interpolate
matrix = zeros(regionCount, maxLevelCount, maxLevelCount+2);
end

function thresholds = getThresholdsFromLevels(levels, thresholds)
thresholds = arrayfun(@(level) getThresholdFromLevel(level+1, thresholds), levels);
end

function threshold = getThresholdFromLevel(level, thresholds)
threshold = uint16(twoValueInterpolate(double(thresholds), level, 0));
end
