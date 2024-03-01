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
            obj.continueCalculation = true;
            results = [];
            count = numel(regions);
            set(regions, "Color", RegionColor.queueColor);

            for index = 1:count
                if obj.continueCalculation
                    region = regions(index);
                    result = obj.trackAndProcessRegion(region);
                    results = [results, result];
                else
                    break;
                end
            end

            set(regions, "Color", RegionColor.unprocessedColor);
        end
    end

    %% Functions to perform tracking
    methods (Access = private)
        function result = trackAndProcessRegion(obj, region)
            set(region, "Color", RegionColor.workingColor); % color region as in-process
            initialResult = obj.initialResult;
            centers = obj.trackRegion(region);
            result = processResult(region, centers, initialResult);
            set(region, "Color", RegionColor.finishedColor); % color region as finished
        end
        function centers = trackRegion(obj, region)
            preprocessor = Preprocessor.fromRegion(region);
            count = obj.getImageCount();
            centers = PointStructurer.preallocate(count);
            progress = ProgressTracker(count);

            for index = 1:count
                continueCalculation = progress.updateIfValid(index);
                if continueCalculation
                    center = obj.trackFrame(index, region, preprocessor);
                    centers(index) = center;
                else
                    break;
                end
            end

            delete(progress);
            obj.continueCalculation = continueCalculation;
            centers = PointStructurer.mergePoints(centers);
        end
        function center = trackFrame(obj, index, region, preprocessor)
            im = obj.getImageInRegion(index, region);
            im = preprocessor.preprocess(im);
            trackingMode = obj.trackingMode;
            center = TrackingAlgorithms.byKeyword(im, trackingMode);
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
