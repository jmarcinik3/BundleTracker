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

    %% Functions to set state information
    methods (Access = protected)
        function setTrackingMode(obj, trackingMode)
            obj.trackingMode = trackingMode;
        end
        function setInitialResult(obj, result)
            obj.initialResult = result;
        end
        function [results, completed] = trackAndProcessRegions(obj, regions)
            set(regions, "Color", RegionColor.queueColor);
            results = arrayfun( ...
                @obj.trackAndProcessIfContinued, regions, ...
                "UniformOutput", false ...
                );
            set(regions, "Color", RegionColor.unprocessedColor);
            
            completed = obj.continueCalculation;
            if completed
                results = cell2mat(results);
            end
            obj.continueCalculation = true;
        end
    end

    %% Functions to perform tracking
    methods (Access = private)
        function result = trackAndProcessIfContinued(obj, region)
            if obj.continueCalculation
                set(region, "Color", RegionColor.workingColor); % color region as in-process
                result = obj.trackAndProcessRegion(region);
                set(region, "Color", RegionColor.finishedColor); % color region as finished
            else
                result = [];
            end
        end
        function result = trackAndProcessRegion(obj, region)
            initialResult = obj.initialResult;
            centers = obj.trackRegion(region);

            result = table2struct([ ...
                struct2table(centers), ...
                struct2table(initialResult) ...
                ]);
            result = appendRegionalMetadata(region, result);
            result = postprocessResults(result);
        end
        function centers = trackRegion(obj, region)
            preprocessor = Preprocessor.fromRegion(region);
            count = obj.getImageCount();
            centers = struct([]);

            progress = ProgressTracker(count);
            for index = 1:count
                continueCalculation = progress.updateIfValid(index - 1);
                if continueCalculation
                    center = obj.trackFrame(index, region, preprocessor);
                    centers = [centers, center];
                else
                    break;
                end
            end
            delete(progress);

            centers = PointStructurer.mergePoints(centers);
            obj.continueCalculation = continueCalculation;
        end
        function center = trackFrame(obj, index, region, preprocessor)
            im = obj.getImageInRegion(index, region);
            im = preprocessor.preprocess(im);
            trackingMode = obj.trackingMode;
            center = TrackingAlgorithms.byKeyword(im, trackingMode);
        end
    end
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