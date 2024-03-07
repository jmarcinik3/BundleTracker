classdef ImageFilepather
    properties (Access = private)
        directory;
        rootname;
        indexFormat;
        extension;
        fileCount;
    end

    methods
        function obj = ImageFilepather(directory, varargin)
            p = inputParser;
            addOptional(p, "Extension", ".tif");
            parse(p, varargin{:});
            extension = p.Results.Extension;

            obj.directory = directory;
            obj.extension = extension;

            [firstFile, fileCount] = getFirstFile(directory, extension);
            if fileCount > 1
                [obj.rootname, obj.indexFormat] = getFileAttributes(firstFile);
            end
            obj.fileCount = fileCount;
        end
    end

    %% Functions to retrieve state information
    methods
        function filepaths = getFilepaths(obj)
            count = obj.getFilecount();
            filepaths = strings(1, count);
            for index = 1:count
                filepath = obj.getFilepath(index);
                filepaths(index) = filepath;
            end
        end
        function filepath = getFilepath(obj, index)
            rootpath = sprintf("%s\\%s", obj.directory, obj.rootname);
            formatStr = sprintf("%%s_%s%%s", obj.indexFormat);
            filepath = sprintf(formatStr, rootpath, index, obj.extension);
        end
        function count = getFilecount(obj)
            count = obj.fileCount;
        end
    end
end


function [rootname, indexFormat] = getFileAttributes(file)
% assumes filename similar to "[rootname]_[index].*"

nameSplits = strsplit( ...
    file.name, ["_", "."], ...
    "CollapseDelimiters", true ...
    );

rootname = nameSplits{1};
indexFormat = sprintf("%%0%dd", strlength(nameSplits{2}));
end

function [file, count] = getFirstFile(directory, extension)
pattern = fullfile(directory, sprintf("*%s", extension));
files = dir(pattern);

count = numel(files);
if count == 0
    file = nan;
else
    file = files(1);
end
end
