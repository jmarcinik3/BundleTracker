function unpaddedMatrix = unpaddedMatrixInRegion(region, im)
regionMask = createMask(region, im);
maskedImage = im;
maskedImage(regionMask == 0) = 0;
unpaddedMatrix = unpadMatrix(maskedImage);
end

function unpaddedMatrix = unpadMatrix(matrix)
[nonzeroRows, nonzeroColumns] = find(matrix);
nonzeroRowsSlice = min(nonzeroRows):max(nonzeroRows);
nonzeroColumnsSlice = min(nonzeroColumns):max(nonzeroColumns);
unpaddedMatrix = matrix(nonzeroRowsSlice, nonzeroColumnsSlice);
end