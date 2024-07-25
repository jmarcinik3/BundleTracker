function rgbs = gray2rgb(ims, fig)
cmap = colormap(fig);
ims = im2uint8(ims);
n = ndims(ims);

if n == 2
    rgbs = ind2rgb(ims, cmap);
    return;
end

[h, w, frameCount] = size(ims);
rgbs = zeros(h, w, 3, frameCount);
for frameIndex = 1:frameCount
    im = ims(:, :, frameIndex);
    rgb = ind2rgb(im, cmap);
    rgbs(:, :, :, frameIndex) = rgb;
end
end