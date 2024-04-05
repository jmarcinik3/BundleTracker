function rgb = gray2rgb(im, fig)
cmap = colormap(fig);
rgb = ind2rgb(im2uint8(im), cmap);
end