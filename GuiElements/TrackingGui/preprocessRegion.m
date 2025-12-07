function ims = preprocessRegion(ims, preprocessor)
frameCount = size(ims, 3);
parfor index = 1:frameCount
    ims(:, :, index) = preprocessor.preprocess(ims(:, :, index));
end
end