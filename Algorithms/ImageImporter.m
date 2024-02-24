classdef ImageImporter < handle
    properties (Access = private)
        %#ok<*PROP>
        filepaths;
        index2image;
        imported;
    end

    methods
        function obj = ImageImporter(filepaths)
            obj.setFilepaths(filepaths);
        end
    end

    %% Functions to retrieve state information
    methods
        function im = getImageInRegion(obj, index, region)
            fullImage = obj.getFullImage(index);
            im = unpaddedMatrixInRegion(region, fullImage);
        end
    end
    methods (Access = protected)
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
    end

    %% Functions to set state information
    methods (Access = protected)
        function setFilepaths(obj, filepaths)
            obj.filepaths = filepaths;
        end
    end
end
