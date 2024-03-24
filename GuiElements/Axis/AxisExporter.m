classdef AxisExporter < handle
    properties (Constant)
        title = "Export Axi&s as Image";
    end
    properties (Access = private, Constant)
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
    methods (Access = protected)
        function exportImage(obj, startDirectory)
            ax = obj.axis;
            AxisExporter.export(ax, startDirectory);
        end
    end
    
    methods (Static)
        function export(ax, startDirectory)
            extensions = AxisExporter.extensions;
            title = AxisExporter.title;
            [filename, directoryPath, ~] = uiputfile(extensions, title, startDirectory);

            if directoryIsChosen(directoryPath)
                filepath = strcat(directoryPath, filename);
                exportgraphics(ax, filepath);
            end
        end
    end
end



function is = directoryIsChosen(directoryPath)
is = directoryPath ~= 0;
end
