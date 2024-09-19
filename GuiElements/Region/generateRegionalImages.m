function regionalImages = generateRegionalImages(regions, im)
regionalImages = {};
for index = numel(regions):-1:1
    region = regions(index);
    regionalImage = MatrixUnpadder.byRegion2d(region, im);
    preprocessor = Preprocessor.fromRegion(region);
    regionalImage = preprocessor.preThreshold(regionalImage);
    regionalImages{index} = regionalImage;
end
end