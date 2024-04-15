classdef AutoThresholder < handle
    properties (Access = protected)
        regionalImages;
        preprocessedImages;
        isSingleThreshold;
    end

    properties (Access = private)
        regionsThresholds;
        calculateThresholds;
        minIntensities;
        maxIntensities;
    end

    methods
        function obj = AutoThresholder(regionalImages, thresholdFcn, maxLevelCount)
            if nargin == 2
                maxLevelCount = 1;
            end

            regionCount = numel(regionalImages);
            preprocessedImages = cellfun( ...
                @preprocessImage, ...
                regionalImages, ...
                "UniformOutput", false ...
                );

            [obj.minIntensities, obj.maxIntensities] = findIntensities(regionalImages);
            obj.isSingleThreshold = maxLevelCount == 1;
            obj.calculateThresholds = thresholdFcn;
            obj.regionalImages = regionalImages;
            obj.preprocessedImages = preprocessedImages;
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
        function im = getPreprocessedImage(obj, index)
            im = obj.preprocessedImages{index};
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

    %% Functions to perform thresholding on region
    methods
        function resetRegionsThresholds(obj)
            preallocateSize = size(obj.regionsThresholds);
            obj.regionsThresholds = zeros(preallocateSize);
        end
        function setThresholdFcn(obj, thresholdFcn)
            obj.calculateThresholds = thresholdFcn;
        end

        function im = rethresholdRegion(obj, regionIndex, levels, levelCount)
            im = obj.getRegionalImage(regionIndex);
            thresholdRange = obj.generateThresholdRange(regionIndex, levels, levelCount);
            noiseRemover = NoiseRemover(thresholdRange);
            im = noiseRemover.get(im);
        end
    end
    methods (Access = protected)
        function thresholdRange = generateThresholdRange(obj, regionIndex, levels, levelCount)
            thresholds = obj.generateRegionThreshold(regionIndex, levelCount);
            thresholdRange = getThresholdsFromLevels(levels, thresholds);
        end
    end

    %% Functions to memoize thresholds
    methods (Access = private)
        function paddedThresholds = calculateRegionThresholds(obj, regionIndex, levelCount)
            im = obj.getPreprocessedImage(regionIndex);
            if obj.isSingleThreshold
                thresholds = obj.calculateThresholds(im);
            else
                thresholds = obj.calculateThresholds(im, levelCount);
            end
            minIntensity = obj.minIntensities(regionIndex);
            maxIntensity = obj.maxIntensities(regionIndex);
            paddedThresholds = [minIntensity, thresholds, maxIntensity];
        end

        function is = thresholdsExist(obj, regionIndex, levelCount)
            minRegionThresholds = max(obj.getRegionThresholds(regionIndex, levelCount));
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

function [minIntensities, maxIntensities] = findIntensities(regionalImages)
regionCount = numel(regionalImages);
minIntensities = zeros(1, regionCount);
maxIntensities = zeros(1, regionCount);
for index = 1:regionCount
    regionalImage = regionalImages{index};
    minIntensities(index) = min(min(regionalImage));
    maxIntensities(index) = max(max(regionalImage));
end
end

function im = preprocessImage(im)
im(im == 0) = min(im(im > 0));
end
