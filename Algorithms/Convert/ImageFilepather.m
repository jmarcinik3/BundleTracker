classdef ImageFilepather
    properties
        directoryPath = '';
        filenames = [''];
        stringFormat = '';
        extension = ".tif";
    end

    methods
        function obj = ImageFilepather(dirpath, extension)
            if nargin < 2
                extension = ".tif";
            end

            [filenames, obj.stringFormat, allMatch] = getFilePattern(dirpath, extension);

            if numel(filenames) == 0
                error([
                    'No valid files found.', ...
                    ' Check whether there exists a file with extension ', ...
                    char(extension), ...
                    '.' ...
                    ]);
            end
            if ~allMatch
                error([ ...
                    'No valid file format found.', ...
                    ' Check that all files follow a consistent string format.', ...
                    ' Files are sorted according to natural alphanumeric ordering.' ...
                    ]);
            end

            obj.filenames = filenames;
            obj.directoryPath = dirpath;
            obj.extension = extension;
        end

        function filepaths = getFilepaths(obj)
            filenames = obj.filenames;
            dirpath = obj.directoryPath;
            fileCount = numel(filenames);

            filepaths = strings(fileCount, 1);
            for index = 1:fileCount
                filename = filenames(index);
                filepath = fullfile(dirpath, filename);
                filepaths(index) = filepath;
            end
        end
    end
end



function [filenames, formatGuess, allMatch] = getFilePattern(dirpath, extension)
fileInfos = dir(strcat(dirpath, '\*', extension));
filenames = getFilenamesFromStruct(fileInfos);
[filenames, ~, expressions] = natsort(filenames);

if numel(filenames) == 0
    formatGuess = "";
    allMatch = true;
    return;
end

constantIndices = getConstantIndices(expressions);
firstDynamicIndex = find(~constantIndices, 1);
startIndex = expressions{1, firstDynamicIndex};

baseFormat = getBaseFormat(expressions);
[formatGuess, allMatch] = guessFormat(filenames, baseFormat, startIndex);
end



function filenames = getFilenamesFromStruct(info)
fileCount = numel(info);
filenames = strings(fileCount, 1);
for index = 1:fileCount
    filenames(index) = info(index).name;
end
end

function baseFormat = getBaseFormat(expressions)
constantIndices = getConstantIndices(expressions);
baseFormat = [];

for index = 1:numel(constantIndices)
    expression = expressions{1, index};
    isNumeric = isnumeric(expression);
    isConstant = constantIndices(index) || ~isNumeric;

    if isNumeric
        expression = num2str(expression);
    end

    if isConstant
        baseFormat = strcat(baseFormat, expression);
        continue;
    end
    baseFormat = strcat(baseFormat, '%xx');
end
end

function constantIndices = getConstantIndices(expressions)
constantIndices = false(size(expressions, 2), 1);
for index = 1:size(expressions, 2)
    expression = cell2mat(expressions(:, index));

    isChar = ischar(expression);
    isConstantInt = isa(expression, "double") & ...
        numel(unique(expression)) == size(expression, 2);
    if isChar || isConstantInt
        constantIndices(index) = true;
    end
end
end



function [stringFormatGuess, allMatch] = guessFormat(filenames, stringFormat, startIndex)
if nargin < 3
    startIndex = 1;
end

constantCharacterCount = strlength(stringFormat) - 3; % -3 to account for %xx
maxFilenameLength = max(strlength(filenames));
maxLeadingZeros = maxFilenameLength - constantCharacterCount;

for leadingZeros = 1:maxLeadingZeros
    integerSpecifier = sprintf("%%0%dd", leadingZeros);
    stringFormatGuess = strrep(stringFormat, "%xx", integerSpecifier);
    allMatch = filesMatchFormat(filenames, stringFormatGuess, startIndex);

    if allMatch
        break;
    end
end
end

function allMatch = filesMatchFormat(filenames, stringFormat, startIndex)
fileCount = numel(filenames);
allMatch = true;

for fileIndex = 1:fileCount
    filename = filenames(fileIndex);
    stringIndex = fileIndex + startIndex - 1;
    filenameGuess = sprintf(stringFormat, stringIndex);

    if ~strcmp(filename, filenameGuess)
        allMatch = false;
        break;
    end
end
end
