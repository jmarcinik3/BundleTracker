function threshold = yanniHorne(im)
% Yanni & Horne 1994

[binCounts, binIntensities] = imhist(im);

binProbs = binCounts ./ sum(binCounts);
minIntensity = binIntensities(find(binCounts, 1, "first"));
maxIntensity = binIntensities(find(binCounts, 1, "last"));
midIntensity = round(0.5 * (minIntensity + maxIntensity));

[~, minIntensityPeak] = max(binCounts(minIntensity:midIntensity));
minIntensityPeak = minIntensityPeak + (minIntensity - 1);
[~, maxIntensityPeak] = max(binCounts(midIntensity+1:maxIntensity));
maxIntensityPeak = maxIntensityPeak + midIntensity;

midIntensityAdjusted = round(0.5 * (minIntensityPeak + maxIntensityPeak));
intensityRange = maxIntensity - minIntensity;
probBelowMid = sum(binProbs(minIntensity:midIntensityAdjusted));
threshold = uint8(intensityRange * probBelowMid);
end