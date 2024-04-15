function threshold = minimumCrossEntropy(im)
binCounts = imhist(im);
binLength = numel(binCounts);

binProbabilities = binCounts / numel(im);
binCdf = cumsum(binProbabilities);
binAreas = (1:numel(binProbabilities)).' .* binProbabilities;
binBelowAreas = cumsum(binAreas);

binAboveAreas =  binBelowAreas(binLength) - binBelowAreas;
binAntiCdf = 1 - binCdf;

imEntropy = sum(binAreas .* log(1:binLength), "all");
lowEntropies = binBelowAreas .* log(binBelowAreas ./ binCdf);
lowEntropies(binCdf <= 0) = 0;
highEntropies = binAboveAreas .* log(binAboveAreas ./ binAntiCdf);
highEntropies(binAntiCdf <= 0) = 0;

crossEntropies = imEntropy - lowEntropies - highEntropies;
[~, minIndex] = min(crossEntropies);
threshold = (minIndex - 1) / binLength;
end
