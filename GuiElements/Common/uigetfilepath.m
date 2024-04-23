function [filepath, isfilepath] = uigetfilepath(varargin)
[filename, directoryPath, ~] = uigetfile(varargin{:});
isfilepath = ischar(filename) || isstring(filename);
if isfilepath
    filepath = strcat(directoryPath, filename);
else
    filepath = "";
end
end