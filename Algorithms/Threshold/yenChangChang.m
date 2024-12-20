function threshold = yenChangChang(im)
% Yen, Chang & Chang 1995

binCounts = imhist(im);
maxIntensity = find(binCounts, 1, "last");
binProbs = binCounts / sum(binCounts);
binCdf = cumsum(binProbs);

lowRatios = (binProbs ./ binCdf') .^ 2;
lowRatios(lowRatios == 0) = 1;
lowEntropies = diag(cumsum(lowRatios .* log(lowRatios), 1));

binAntiCdf = 1 - binCdf;
highRatios = (binProbs ./ binAntiCdf') .^ 2;
highRatios(highRatios == 0) = 1;
highPartialSums = cumsum(highRatios .* log(highRatios), 1);
highEntropies = highPartialSums(maxIntensity, :)' - diag(highPartialSums);

entropies = lowEntropies + highEntropies;
[~, threshold] = min(entropies);
threshold = uint8(threshold);
end
