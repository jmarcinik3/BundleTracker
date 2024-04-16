classdef AxisExporter < handle
    properties (Constant)
        extensions = { ...
            '*.png', "Portable Network Graphics (PNG)"; ...
            '*.jpg;*.jpeg', "Joint Photographic Experts Group (JPEG)"; ...
            '*.tif;*.tiff', "Tagged Image File Format (TIFF)"; ...
            '*.gif', "Graphics Interchange Format (GIF)"; ...
            '*.eps', "Encapsulated PostScript® (EPS)"; ...
            '*.pdf', "Portable Document Format (PDF)";
            '*.emf', "Enhanced Metafile for Windows® systems only (EMF)";
            }; % compatible extensions to save image as
    end

    properties (Access = private)
        axis;
    end

    methods
        function obj = AxisExporter(ax)
            obj.axis = ax;
        end
    end

    %% Functions to export image
    methods
        function exportImage(obj, startDirectory)
            ax = obj.axis;
            AxisExporter.export(ax, startDirectory);
        end
    end

    methods (Static)
        function export(ax, path)
            [filepath, isfilepath] = getFilepath(path);
            if isfilepath
                exportgraphics(ax, filepath);
            end
        end
    end
end



function [filepath, isfilepath] = getFilepath(path)
if isfolder(path)
    [filepath, isfilepath] = fileFromDirectoryPath(path);
elseif isstring(path) || ischar(path)
    isfilepath = true;
    filepath = path;
else
    error("Path must be a directory of file path.")
end
end

function [filepath, isfilepath] = fileFromDirectoryPath(startDirectory)
extensions = AxisExporter.extensions;
title = SettingsParser.getExportAxisLabel();
[filepath, isfilepath] = uiputfilepath(extensions, title, startDirectory);
end

