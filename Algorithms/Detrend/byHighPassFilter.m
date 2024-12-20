function [x, y, info] = byHighPassFilter(x, y)
x = detrendTrace(x);
y = detrendTrace(y);
info = [];
end

function y = detrendTrace(x)
[xPsd, fPsd] = pwelch(x);
psdPeakIndex = findProminentPeak(xPsd);
psdPeakFrequency = fPsd(psdPeakIndex);
y = highpass( ...
    x, ...
    psdPeakFrequency / 2, ...
    1 / (2*pi), ...
    "Steepness", 0.5, ...
    "StopbandAttenuation", 60 ...
    );
end

function index = findProminentPeak(x)
[~, indices, ~, prominences] = findpeaks(x);
[~, prominenceArgsort] = sort(prominences, "descend");
prominentHighFrequencyIndex = find( ...
    prominenceArgsort > nthroot(numel(x), 3), ...
    1, ...
    "first" ...
    );
index = indices(prominentHighFrequencyIndex);
end
