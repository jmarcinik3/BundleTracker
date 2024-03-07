classdef ImageImporter < handle
    properties (Access = private, Constant)
        parallelThreshold = 5000;
    end

    properties (Access = private)
        filepaths;
    end

    methods
        function obj = ImageImporter(filepaths)
            obj.setFilepaths(filepaths);
        end
    end

    %% Functions to retrieve state information
    methods (Access = protected)
        function im = getImageInRegion(obj, index, region)
            fullImage = obj.getFullImage(index);
            im = unpaddedMatrixInRegion(region, fullImage);
        end
        function ims = getImage3dInRegion(obj, region)
            imageCount = obj.getImageCount();
            ims = obj.preallocate3dImage(region);

            if imageCount > obj.parallelThreshold
                progress = ProgressBar(imageCount, "Loading Images");
                parfor index = 2:imageCount
                    ims(index, :, :) = obj.getImageInRegion(index, region);
                    count(progress);
                end
            else
                for index = 2:imageCount
                    ims(index, :, :) = obj.getImageInRegion(index, region);
                end
            end
        end

        function count = getImageCount(obj)
            filepaths = obj.filepaths;
            count = numel(filepaths);
        end
        function filepath = getFilepath(obj, index)
            filepath = obj.filepaths(index);
        end
    end
    methods (Access = private)
        function im = getFullImage(obj, index)
            filepath = obj.getFilepath(index);
            im = imread(filepath);
        end
        function ims = preallocate3dImage(obj, region)
            count = obj.getImageCount();
            im = obj.getImageInRegion(1, region);
            [w, h] = size(im);
            ims = zeros(count, w, h);
            ims(1, :, :) = im;
        end
    end

    %% Functions to set state information
    methods (Access = protected)
        function setFilepaths(obj, filepaths)
            obj.filepaths = filepaths;
        end
    end
end
