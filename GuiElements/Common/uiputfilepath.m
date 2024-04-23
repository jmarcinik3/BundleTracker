function [filepath, isfilepath] = uiputfilepath(varargin)
[filename, directoryPath, ~] = uiputfile(varargin{:});
isfilepath = ischar(filename) || isstring(filename);
if isfilepath
    filepath = strcat(directoryPath, filename);
else
    filepath = "";
end
end