classdef RegionTracker < ImageImporter
    properties (Access = private)
        trackingMode;
        initialResult;
        continueCalculation = true;
    end

    methods
        function obj = RegionTracker(varargin)
            p = inputParser;
            addOptional(p, "Filepaths", []);
            addOptional(p, "TrackingMode", TrackingAlgorithms.centerOfMass);
            addOptional(p, "InitialResult", struct());
            parse(p, varargin{:});
            filepaths = p.Results.Filepaths;
            trackingMode = p.Results.TrackingMode;
            initialResult = p.Results.InitialResult;

            obj@ImageImporter(filepaths);
            obj.trackingMode = trackingMode;
            obj.initialResult = initialResult;
        end
    end

    %% Functions to retrieve state information
    methods (Access = protected)
        function was = trackingWasCompleted(obj)
            was = obj.continueCalculation;
        end
    end

    %% Functions to set state information
    methods (Access = protected)
        function setTrackingMode(obj, trackingMode)
            obj.trackingMode = trackingMode;
        end
        function setInitialResult(obj, result)
            obj.initialResult = result;
        end
        function results = trackAndProcessRegions(obj, regions)
            results = {};
            regionCount = numel(regions);
            set(regions, "Color", RegionColor.queueColor);
            
            for index = 1:regionCount
                region = regions(index);
                result = obj.trackAndProcessRegion(region, index);
                results{index} = result;
            end

            results = cell2mat(results);
            set(regions, "Color", RegionColor.unprocessedColor);
        end
    end

    %% Functions to perform tracking
    methods (Access = private)
        function result = trackAndProcessRegion(obj, region, regionIndex)
            set(region, "Color", RegionColor.workingColor); % color region as in-process
            initialResult = obj.initialResult;
            centers = obj.trackRegion(region, regionIndex);
            result = processResult(region, centers, initialResult);
            set(region, "Color", RegionColor.finishedColor); % color region as finished
        end

        function centers = trackRegion(obj, region, regionIndex)
            frameCount = obj.getImageCount();
            centers = PointStructurer.preallocate(frameCount);
            ims = obj.getPreprocessedImage3d(region);
            trackingMode = obj.trackingMode;
            
            taskName = sprintf("Region %d", regionIndex);
            progress = ProgressBar(frameCount, taskName);
            parfor index = 1:frameCount
                im = squeeze(ims(index, :, :));
                centers(index) = TrackingAlgorithms.byKeyword(im, trackingMode);
                count(progress);
            end

            centers = PointStructurer.mergePoints(centers);
        end

        function ims = getPreprocessedImage3d(obj, region)
            ims = obj.getImage3dInRegion(region);
            preprocessor = Preprocessor.fromRegion(region);
            ims = preprocessor.preprocess(ims);
        end
    end
end



function result = processResult(region, centers, initialResult)
result = table2struct([ ...
    struct2table(centers), ...
    struct2table(initialResult) ...
    ]);
result = appendRegionalMetadata(region, result);
result = postprocessResults(result);
end

function result = appendRegionalMetadata(region, result)
regionParser = RegionParser(region);
result = regionParser.appendMetadata(result);
end

function results = postprocessResults(results)
postprocessor = Postprocessor(results);
postprocessor.process();
results = postprocessor.getPostprocessedResults();
end
