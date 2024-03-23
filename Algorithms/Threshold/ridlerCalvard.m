function newThreshold = ridlerCalvard(im)
% Reference: T.W. Ridler, S. Calvard, Picture thresholding using an iterative selection method,
% IEEE Trans. System, Man and Cybernetics, SMC-8 (1978) 630-632.

[binCount, binIntensity] = imhist(im);
binLength = numel(binCount);
binAreasBelow = cumsum(binCount .* binIntensity);
binCountsBelow = cumsum(binCount);
binTotalArea = binAreasBelow(binLength);
binTotalCount = binCountsBelow(binLength);

newThreshold = round(binTotalArea ./ binTotalCount);
deltaThreshold = 1;

while deltaThreshold > 0
    [~, nearThreshold] = min(abs(binIntensity - newThreshold));

    binAreaBelow = binAreasBelow(nearThreshold);
    binCountBelow = binCountsBelow(nearThreshold);
    meanThresholdBelow = binAreaBelow / binCountBelow;
    meanThresholdAbove = (binTotalArea - binAreaBelow) / (binTotalCount - binCountBelow);

    oldThreshold = newThreshold;
    newThreshold = (meanThresholdBelow + meanThresholdAbove) / 2;
    deltaThreshold = abs(newThreshold - oldThreshold);
end
end
