function ims = normalizeImage(ims, thresholds)
normalize = @(ims) mat2gray(ims);
if nargin == 2
    normalize = @(ims) mat2gray(ims, thresholds);
end

if ismatrix(ims)
    ims = normalize(ims);
    return;
end

for index = 1:size(ims, 3)
    ims(:, :, index) = normalize(ims(:, :, index));
end
end