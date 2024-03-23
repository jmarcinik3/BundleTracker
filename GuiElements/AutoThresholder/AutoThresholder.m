classdef AutoThresholder < handle
    properties (Access = protected)
        regionalImages;
        isSingleThreshold;
    end

    properties (Access = private)
        regionsThresholds;
        calculateThresholds;
    end

    methods
        function obj = AutoThresholder(regionalImages, thresholdFcn, maxLevelCount)
            if nargin == 2
                maxLevelCount = 1;
            end
            obj.isSingleThreshold = maxLevelCount == 1;
            regionCount = numel(regionalImages);

            obj.calculateThresholds = thresholdFcn;
            obj.regionalImages = regionalImages;
            obj.regionsThresholds = preallocateRegionThresholds(regionCount, maxLevelCount);
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

        function thresholds = generateRegionThreshold(obj, regionIndex, levelCount)
            if levelCount == 0
                thresholds = 0;
            elseif obj.thresholdsExist(regionIndex, levelCount)
                thresholds = obj.getRegionThresholds(regionIndex, levelCount);
            else
                thresholds = obj.calculateRegionThresholds(regionIndex, levelCount);
                obj.setRegionThresholds(regionIndex, levelCount, thresholds);
            end
        end
    end
    methods (Access = private)

    end

    %% Functions to perform thresholding on region
    methods (Access = protected)
        function im = rethresholdRegion(obj, regionIndex, levels, levelCount)
            im = obj.getRegionalImage(regionIndex);
            thresholdRange = obj.generateThresholdRange(regionIndex, levels, levelCount);
            noiseRemover = NoiseRemover(thresholdRange);
            im = noiseRemover.get(im);
        end
        function thresholdRange = generateThresholdRange(obj, regionIndex, levels, levelCount)
            thresholds = obj.generateRegionThreshold(regionIndex, levelCount);
            thresholdRange = getThresholdsFromLevels(levels, thresholds);
        end
    end

    %% Functions to memoize thresholds
    methods (Access = private)
        function paddedThresholds = calculateRegionThresholds(obj, regionIndex, levelCount)
            im = obj.getRegionalImage(regionIndex);
            if obj.isSingleThreshold
                thresholds = obj.calculateThresholds(im);
            else
                thresholds = obj.calculateThresholds(im, levelCount);
            end
            paddedThresholds = [0, thresholds, Inf];
        end

        function is = thresholdsExist(obj, regionIndex, levelCount)
            minRegionThresholds = obj.regionsThresholds(regionIndex, levelCount, 2);
            is = minRegionThresholds > 0;
        end
        function thresholds = getRegionThresholds(obj, regionIndex, levelCount)
            thresholds = obj.regionsThresholds(regionIndex, levelCount, :);
            thresholds = squeeze(thresholds);
        end
        function setRegionThresholds(obj, regionIndex, levelCount, thresholds)
            obj.regionsThresholds(regionIndex, levelCount, 1:levelCount+2) = thresholds;
        end
    end
end



function matrix = preallocateRegionThresholds(regionCount, maxLevelCount)
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
