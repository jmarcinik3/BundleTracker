classdef RegionTracker < ImageImporter
    properties (Constant)
        queueColor = "red";
        workingColor = "yellow";
        finishedColor = "green";
    end

    properties (Access = private)
        %#ok<*PROP>
        %#ok<*PROPLC>
        trackingMode;
        initialResult;
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
        function results = trackAndProcessRegions(obj, regions)
            set(regions, "Color", RegionTracker.queueColor);
            results = arrayfun(@obj.trackAndProcessRegion, regions);
        end
    end

    %% Functions to perform tracking
    methods (Access = private)
        function result = trackAndProcessRegion(obj, region)
            set(region, "Color", RegionTracker.workingColor); % color region as in-process
            initialResult = obj.initialResult;
            centers = obj.trackRegion(region);

            result = table2struct([ ...
                struct2table(centers), ...
                struct2table(initialResult) ...
                ]);
            result = appendRegionalMetadata(region, result);
            result = postprocessResults(result);

            set(region, "Color", RegionTracker.finishedColor); % color region as finished
        end
        function centers = trackRegion(obj, region)
            preprocessor = Preprocessor.fromRegion(region);
            count = obj.getImageCount();
            centers = struct([]);

            progress = ProgressTracker(count);
            for index = 1:count
                im = obj.getImageInRegion(index, region);
                im = preprocessor.preprocess(im);
                center = obj.trackFrame(im);
                centers = [centers, center];
                progress.updateIfNeeded(index);
            end
            delete(progress);

            centers = PointStructurer.mergePoints(centers);
        end
        function center = trackFrame(obj, im)
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