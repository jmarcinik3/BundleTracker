function level = triangleThreshold(im)
%     Triangle algorithm
%     This technique is due to Zack (Zack GW, Rogers WE, Latt SA (1977),
%     "Automatic measurement of sister chromatid exchange frequency",
%     J. Histochem. Cytochem. 25 (7): 741–53, )
%     A line is constructed between the maximum of the histogram at
%     (b) and the lowest (or highest depending on context) value (a) in the
%     histogram. The distance L normal to the line and between the line and
%     the histogram h[b] is computed for all values from a to b. The level
%     where the distance between the histogram and the line is maximal is the
%     threshold value (level). This technique is particularly effective
%     when the object pixels produce a weak peak in the histogram.

%     Use Triangle approach to compute threshold based on a 1D histogram.

%     INPUTS
%         im :   gray level image
%     OUTPUT
%         level   :   threshold value in the range [0, 1];
%
%     Dr B. Panneton, June, 2010
%     Agriculture and Agri-Food Canada
%     St-Jean-sur-Richelieu, Qc, Canad
%     bernard.panneton@agr.gc.ca


imClass = class(im);
%   Find maximum of histogram and its location along the x axis
binCount = imhist(im);
binLength = numel(binCount);
[~, maxIndex] = max(binCount);
maxIndex = round(mean(maxIndex));
maxBinCount = binCount(maxIndex);

%   Find location of first and last non-zero values.
indexNonzero = find(binCount > 0);
firstNonzero = indexNonzero(1);
lastNonzero = indexNonzero(end);

%   Pick side as side with longer tail. Assume one tail is longer.
leftSpan = maxIndex - firstNonzero;
rightSpan = lastNonzero - maxIndex;
binCount = binCount';
rightSpanLongerThanLeft = rightSpan > leftSpan;

if rightSpanLongerThanLeft 
    binCount = fliplr(binCount);
    edgeToZeroDistance = binLength - lastNonzero + 1;
    edgeToMaxDistance = binLength - maxIndex + 1;
else
    edgeToZeroDistance = firstNonzero;
    edgeToMaxDistance = maxIndex;
end
zeroToMaxDistance = edgeToMaxDistance - edgeToZeroDistance;

%   Compute parameters of the straight line from first non-zero to peak
%   To simplify, shift x axis by a (bin number axis)
lineSlope = maxBinCount / zeroToMaxDistance;

%   Compute distances
zeroToMaxDistances = 0:zeroToMaxDistance;
bottomToHistDistance = binCount(zeroToMaxDistances + edgeToZeroDistance);
beta = bottomToHistDistance + zeroToMaxDistances / lineSlope;
lineX = beta / (lineSlope + 1 / lineSlope);
lineY = lineSlope * lineX;
lineToHistDistances = sqrt((lineY-bottomToHistDistance).^2 + (lineX-zeroToMaxDistances).^2);

%   Obtain threshold as the location of maximum L.
[~, level] = max(lineToHistDistances);
level = edgeToZeroDistance + mean(level);

%   Flip back if necessary
if rightSpanLongerThanLeft
    level = binLength - level + 1;
end

level = level / binLength;
end
