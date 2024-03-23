function threshold = kittlerIllingworth(im)
% T = KITTLER(im) computes a global threshold of the image
% according to the method described by J. KITTLER and J. ILLINGWORTH.

[binCounts, binLocations] = imhist(im);
binlength = numel(binCounts);

bccs = cumsum(binCounts);
ba = binCounts .* binLocations;
bi = cumsum(ba);
bis = cumsum(ba .* binLocations);
bccsr = 1 ./ bccs;
sigmaF = sqrt(bis .* bccsr - (bi .* bccsr).^2);

bccsi = bccs(binlength) - bccs;
bii = bi(binlength) - bi;
bisi = bis(binlength) - bis;
bccsir = 1 ./ bccsi;
sigmaB = sqrt(bisi .* bccsir - (bii .* bccsir).^2);

binCdf = bccs * bccsr(binlength);
thresholds = binCdf .* log(sigmaF) ...
    + (1-binCdf) .* log(sigmaB) ...
    - binCdf .* log(binCdf) ...
    - (1-binCdf) .* log(1-binCdf);
thresholds(~isfinite(thresholds)) = Inf;

[~, minIndex] = min(thresholds);
threshold = binLocations(minIndex);
end
