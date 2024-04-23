function regionalImages = generateRegionalImages(regions, im)
for index = numel(regions):-1:1
    region = regions(index);
    regionalImage = MatrixUnpadder.byRegion2d(region, im);
    regionalImages{index} = regionalImage;
end
end