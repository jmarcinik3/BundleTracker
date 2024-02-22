classdef ImageExporter
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

    methods (Static)
        function export(ax, startDirectory)
            extensions = ImageExporter.extensions;
            [filename, directoryPath, ~] = uiputfile(extensions, "Save Image", startDirectory);

            if isValidDirectoryPath(directoryPath)
                filepath = strcat(directoryPath, filename);
                exportgraphics(ax, filepath);
            end
        end
    end
end



function is = isValidDirectoryPath(directoryPath)
is = directoryPath ~= 0;
end