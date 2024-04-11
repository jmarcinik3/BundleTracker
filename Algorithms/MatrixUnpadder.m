classdef MatrixUnpadder
    methods (Static)
        function unpaddedMatrix = byRegion2d(region, im)
            if isstring(im)
                im = imread(im);
            end
            regionMask = region.createMask(im);
            unpaddedMatrix = MatrixUnpadder.byMask2d(regionMask, im);
        end

        function unpaddedMatrix = byMask2d(mask, im)
            maskedImage = im;
            maskedImage(~mask) = 0;
            unpaddedMatrix = MatrixUnpadder.unpad(maskedImage);
        end

        function unpaddedMatrix = unpad(matrix)
            [rowsSlice, columnsSlice] = MatrixUnpadder.slicesByMatrix(matrix);
            unpaddedMatrix = matrix(rowsSlice, columnsSlice);
        end

        function [rowsSlice, columnsSlice] = slicesByRegion(region, im)
            if isstring(im)
                im = imread(im);
            end
            regionMask = region.createMask(im);
            [rowsSlice, columnsSlice] = MatrixUnpadder.slicesByMatrix(regionMask);
        end

        function [rowsSlice, columnsSlice] = slicesByMatrix(matrix)
            [nonzeroRows, nonzeroColumns] = find(matrix);
            rowsSlice = min(nonzeroRows):max(nonzeroRows);
            columnsSlice = min(nonzeroColumns):max(nonzeroColumns);
        end

        function pixelRegion =  pixelsBySlices(rowsSlice, columnsSlice)
            rowMin = min(rowsSlice);
            rowMax = max(rowsSlice);
            columnMin = min(columnsSlice);
            columnMax = max(columnsSlice);
            pixelRegion = {[rowMin, rowMax], [columnMin, columnMax]};
        end

        function pixelRegion = pixelsByRegion(region, im)
            [rowsSlice, columnsSlice] = MatrixUnpadder.slicesByRegion(region, im);
            pixelRegion = MatrixUnpadder.pixelsBySlices(rowsSlice, columnsSlice);
        end

        function pixelRegion = pixelsByMatrix(matrix)
            [rowsSlice, columnsSlice] = find(matrix);
            pixelRegion = MatrixUnpadder.pixelRegionBySlice(rowsSlice, columnsSlice);
        end
    end
end

