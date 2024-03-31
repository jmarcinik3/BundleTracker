function threshold = johannsenBille(im)
% Johannsen & Bille 1982

binCounts = imhist(im);
binLength = numel(binCounts);
binProbs = binCounts / sum(binCounts);

binCdf = cumsum(binProbs);
binLogCdf = log(binCdf);
binEntropies = binProbs .* log(binProbs);
binCdfEntropies = binCdf .* log(binCdf);

St2 = binEntropies ./ binCdf;
St3 = binCdfEntropies(1:binLength-1) ./ binCdf(2:binLength);
St = binLogCdf(1:binLength-1) - St2(1:binLength-1) - St3;

binAntiCdf = 1 - binCdf;
binLogAntiCdf = log(binAntiCdf);
binAntiCdfEntropies = binAntiCdf .* log(binAntiCdf);

Stb2 = binEntropies(2:binLength) ./ binAntiCdf(1:binLength-1);
Stb3 = binAntiCdfEntropies(2:binLength) ./ binAntiCdf(1:binLength-1);
Stb = binLogAntiCdf(1:binLength-1) - Stb2 - Stb3;

Stot = St(2:binLength-1) + Stb(1:binLength-2);
[~, threshold] = min(Stot);
threshold = uint8(threshold + 1);
end