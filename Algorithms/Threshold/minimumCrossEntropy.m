function threshold = minimumCrossEntropy(im)
binCounts = imhist(im);
binLength = numel(binCounts);

binProbabilities = binCounts / numel(im);
binCdf = cumsum(binProbabilities);
binAreas = (1:numel(binProbabilities))' .* binProbabilities;
binBelowAreas = cumsum(binAreas);
binTotalArea = binBelowAreas(binLength);

imEntropy = sum(binAreas .* log(1:binLength), "all");
minimumEntropy = Inf;
for binIndex = 1:binLength
    binBelowArea = binBelowAreas(binIndex);
    binBelowProbability = binCdf(binIndex);
    binAboveProbability = 1 - binBelowProbability;

    crossEntropy = imEntropy;
    if binBelowProbability > 0
        lowEntropy = -binBelowArea * log(binBelowArea / binBelowProbability);
        crossEntropy = crossEntropy + lowEntropy;
    end
    if binAboveProbability > 0
        binAboveArea = binTotalArea - binBelowArea;
        highEntropy = -binAboveArea * log(binAboveArea / binAboveProbability);
        crossEntropy = crossEntropy + highEntropy;
    end
    
    if crossEntropy < minimumEntropy
        minimumEntropy = crossEntropy;
        threshold = (binIndex - 1) / binLength;
    end
end
end
