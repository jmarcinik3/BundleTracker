function ims = normalizeImage(ims)
if ismatrix(ims)
    ims = mat2gray(ims);
    return;
end

for index = 1:size(ims, 3)
    ims(:, :, index) = mat2gray(ims(:, :, index));
end
end