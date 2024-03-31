function thresholds = fuzzyEntropy(im, levelCount, varargin)
binCounts = imhist(im) / numel(im);
fuzzyParameters = differentialEvolution( ...
    binCounts', ...
    2 * levelCount, ...
    @calculateFuzzyEntropy, ...
    varargin{:} ...
    );
fuzzyParameters = [ ...
    fuzzyParameters(1:2:end); ...
    fuzzyParameters(2:2:end) ...
    ];
thresholds = mean(fuzzyParameters, 1);
thresholds = uint8(round(thresholds));
end



function entropy = calculateFuzzyEntropy(x, binCounts)
x = [1, 1, x+1, 256, 256];
probs = [];

for trapIndex = 1:2:length(x)-3
    a = x(trapIndex);
    b = x(trapIndex + 1);
    c = x(trapIndex + 2);
    d = x(trapIndex + 3);

    prob = isTrapezoid(a:d, a, b, c, d) .* binCounts(a:d);
    probs = [probs, prob / sum(prob)];
end

entropy = calculateEntropy(probs);
end

function is = isTrapezoid(x, a, b, c, d)
is = max(min(min((x - a) / (b - a), (d - x) / (d - c)), 1), 0);
end

function entropy = calculateEntropy(probs)
probs = probs .* log(probs);
probs(isnan(probs)) = 0;
entropy = -sum(probs, "all");
end
