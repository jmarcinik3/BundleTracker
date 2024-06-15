classdef CrossCorrelation < handle
    properties (Access = private)
        compareMode;
        upsampleFactor;
        previousFft;
        previousCenter;
    end

    methods
        function obj = CrossCorrelation(firstFrame, varargin)
            p = inputParser;
            addOptional(p, "UpsampleFactor", 100);
            addOptional(p, "CompareMode", "First");
            parse(p, varargin{:});

            obj.compareMode = p.Results.CompareMode;
            obj.upsampleFactor = p.Results.UpsampleFactor;
            obj.previousFft = fft2(firstFrame);
            obj.previousCenter = ErrorPropagator([0, 0], [0, 0]);
        end

        function center = offsetWithError(obj, im)
            switch obj.compareMode
                case "First"
                    center = obj.offsetFirstMode(im);
                case "Consecutive"
                    center = obj.offsetConsecutiveMode(im);
            end
        end

        function center = offsetFirstMode(obj, im)
            [xmean, ymean, xyerr] = dftregistration(fft2(im), obj.previousFft, obj.upsampleFactor);
            [xerr, yerr] = calculateErrorComponents(xmean, ymean, xyerr);
            center = PointStructurer.asPoint(xmean, ymean, xerr, yerr);
        end

        function center = offsetConsecutiveMode(obj, im)
            newFft = fft2(im);
            [dx, dy, xyerr] = dftregistration(newFft, obj.previousFft, obj.upsampleFactor);
            [xerr, yerr] = calculateErrorComponents(dx, dy, xyerr);
            
            dxy = ErrorPropagator([dx, dy], [xerr, yerr]);
            xy = dxy + obj.previousCenter;

            center = PointStructurer.asPoint( ...
                xy.Value(1), ...
                xy.Value(2), ...
                xy.Error(1), ...
                xy.Error(2) ...
                );
            obj.previousFft = newFft;
            obj.previousCenter = xy;
        end
    end
end



function [xerr, yerr] = calculateErrorComponents(xmean, ymean, xyerr)
if xmean == 0
    xerr = 0;
    yerr = xyerr;
    return;
end
if ymean == 0
    xerr = xyerr;
    yerr = 0;
    return;
end

xErrorProportion = abs(xmean) / sqrt(xmean.^2 + ymean.^2);
xerr = xErrorProportion * xyerr;
yerr = (1 - xErrorProportion) * xyerr;
end

function [rowShift, columnShift, shiftError] = dftregistration(frameFft1, frameFft2, upsampleFactor)
% Modified by Joseph Marcinik (2024)
% Citation for this algorithm:
% Manuel Guizar-Sicairos, Samuel T. Thurman, and James R. Fienup,
% "Efficient subpixel image registration algorithms," Opt. Lett. 33,
% 156-158 (2008).

frameFft = cat(3, frameFft1, frameFft2);
[rowShift, columnShift] = calculateShifts(frameFft);
[rowShift, columnShift, correlationMax] = upsampledShifts(rowShift, columnShift, frameFft, upsampleFactor);

[rowCount, columnCount] = size(frameFft2);
if rowCount == 1, rowShift = 0; end
if columnCount == 1, columnShift = 0; end

shiftError = calculateError(correlationMax, frameFft);
end

function [rowShift, columnShift] = calculateShifts(frameFft)
[rowCount, columnCount, ~] = size(frameFft);

crossCorrelation = ifft2(paddedFft( ...
    frameFft(:, :, 1) .* conj(frameFft(:, :, 2)), ...
    [2*rowCount, 2*columnCount] ...
    ));
[rowShiftIndex, columnShiftIndex] = indicesAtMaxSquare(crossCorrelation);

rowShift = shiftFromIndex(rowCount, rowShiftIndex);
columnShift = shiftFromIndex(columnCount, columnShiftIndex);
end
function [rowShift, columnShift, correlationMax] = ...
    upsampledShifts(rowShift, columnShift, frameFft, upsampleFactor)

rowShift = upsampledSlice(rowShift, upsampleFactor);
columnShift = upsampledSlice(columnShift, upsampleFactor);
dftShift = fix(ceil(1.5 * upsampleFactor)/2);
pixelCountOut = ceil(1.5 * upsampleFactor);

crossCorrelation = conj(upsampleFft( ...
    frameFft(:, :, 2) .* conj(frameFft(:, :, 1)), ...
    pixelCountOut, ...
    pixelCountOut, ...
    upsampleFactor, ...
    dftShift - rowShift * upsampleFactor, ...
    dftShift - columnShift * upsampleFactor ...
    ));

[rowLocation, columnLocation] = indicesAtMaxSquare(crossCorrelation);
correlationMax = crossCorrelation(rowLocation, columnLocation);
rowShift = rowShift + (rowLocation - dftShift - 1) / upsampleFactor;
columnShift = columnShift + (columnLocation - dftShift - 1) / upsampleFactor;
end

function fftOut = paddedFft(fftIn, sizeOut)
% Pads or crops the Fourier transform to the desired ouput size. Taking
% care that the zero frequency is put in the correct place for the output
% for subsequent FT or IFT. Can be used for Fourier transform based
% interpolation, i.e. dirichlet kernel interpolation.

sizeIn = size(fftIn);
fftIn = fftshift(fftIn);

centerOut = floor(sizeOut/2) - floor(sizeIn/2);
outStartInds = max(centerOut + 1, 1);
outEndInds = min(centerOut + sizeIn, sizeOut);
inStartInds = max(-centerOut + 1, 1);
inEndInds = min(-centerOut + sizeOut, sizeIn);

fftOut = zeros(sizeOut);
fftOut(outStartInds(1):outEndInds(1), outStartInds(2):outEndInds(2)) = ...
    fftIn(inStartInds(1):inEndInds(1), inStartInds(2):inEndInds(2));
fftOut = ifftshift(fftOut) * prod(sizeOut) / prod(sizeIn);
end
function fftOut = upsampleFft(fftIn, rowCountOut, columnCountRow, upsampleFactor, rowOffset, columnOffset)
[rowCountIn, columnCountIn] = size(fftIn);

columnKernel = exp( ...
    -2*pi*1i / (columnCountIn * upsampleFactor) ...
    * ( ifftshift(0:columnCountIn-1).' - floor(columnCountIn/2) ) ...
    * ( (0:columnCountRow-1) - columnOffset ) ...
    );
rowKernel = exp( ...
    -2*pi*1i / (rowCountIn * upsampleFactor) ...
    * ( (0:rowCountOut-1).' - rowOffset ) ...
    * ( ifftshift(0:rowCountIn-1) - floor(rowCountIn/2)  ) ...
    );

fftOut = rowKernel * fftIn * columnKernel;
end

function shiftError = calculateError(correlationMax, frameFft)
r = prod(sum(abs(frameFft).^2, [1, 2]));
shiftError = 1 - abs(correlationMax).^2 / r;
shiftError = sqrt(abs(shiftError));
end
function indices = upsampledSlice(pixelCount, upsampleFactor)
indices = round(pixelCount * upsampleFactor) / upsampleFactor;
end
function pixelShift = shiftFromIndex(pixelCount, pixelIndex)
pixelShifts = ifftshift(-fix(pixelCount):ceil(pixelCount) - 1);
pixelShift = pixelShifts(pixelIndex) / 2;
end
function [rowShift, columnShift] = indicesAtMaxSquare(matrix)
[~, maxIndex] = max(abs(matrix), [], "all");
[rowShift, columnShift] = ind2sub(size(matrix), maxIndex);
end

