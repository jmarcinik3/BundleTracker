classdef ImageImporter < handle
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
        function ims = getImage3dInRegion(obj, region)
            imageCount = obj.getImageCount();
            ims = obj.preallocate3dImage(region);
            filepaths = obj.filepaths;
            pixelRegion = MatrixUnpadder.pixelsByRegion(region, filepaths(1));
            
            progress = ProgressBar(imageCount, "Loading Images");
            parfor index = 2:imageCount
                ims(:, :, index) = imread(filepaths(index), "PixelRegion", pixelRegion);;
                count(progress);
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
        function ims = preallocate3dImage(obj, region)
            count = obj.getImageCount();
            filepath = obj.getFilepath(1);
            im = MatrixUnpadder.byRegion2d(region, filepath);
            [w, h] = size(im);
            ims = zeros(w, h, count);
            ims(:, :, 1) = im;
        end
    end

    %% Functions to set state information
    methods (Access = protected)
        function setFilepaths(obj, filepaths)
            obj.filepaths = filepaths;
        end
    end
end
