function regionalImages = generateRegionalImages(regions, im)
regionCount = numel(regions);
for index = regionCount:-1:1
    region = regions(index);
    regionalImage = MatrixUnpadder.byRegion2d(region, im);
    regionalImages{index} = regionalImage;
end
end