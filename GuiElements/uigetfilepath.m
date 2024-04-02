function filepath = uigetfilepath(varargin)
[filename, directoryPath, ~] = uigetfile(varargin{:});
if filename
    filepath = strcat(directoryPath, filename);
else
    filepath = "";
end
end