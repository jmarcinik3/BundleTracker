function text = formatNumberWithUncertainty(datum, sigma, varargin)
p = inputParser;
addOptional(p, "Precision", 1); % number of digits in decimal
addOptional(p, "Format", 'n'); % 'n'ormal, 'm'etric, 's'cientific
addOptional(p, "UseTex", false); % set true to use TeX renderer; false otherwise
parse(p, varargin{:});
precision = p.Results.Precision;
outputFormat = p.Results.Format;
useTex = p.Results.UseTex;

numberSign = sign(datum);
number = [abs(datum), sigma];
exponent = floor(log10(number));
exponentShift = calculateExponentShift(exponent(1), outputFormat);

exponent = exponent - exponentShift;
exponentLSD = exponent(2) - precision + 1;
numberDisplay = round(number / 10^(exponentShift + exponentLSD));
numberDisplay(1) = numberDisplay(1) * 10^exponentLSD;

% does the datum or signal increment in its log interval? (.99 -> 1.00)
exponentDisplay = floor(log10(numberDisplay));
fixDatum = exponentDisplay(1) > exponent(1);
fixSigma = exponentDisplay(2) > exponent(2) - exponentLSD;

if fixDatum
    if outputFormat == 's'
        exponentShift = exponentShift + 1;
        numberDisplay(1) = numberDisplay(1) / 10;
        exponent(2) = exponent(2) - 1;
        exponentLSD  = exponentLSD - 1;
    elseif (outputFormat == 'e' || outputFormat == 'm') ...
            && numberDisplay(1) == 1000
        exponentShift = exponentShift + 3;
        numberDisplay(1) = 1;
        exponent(2) = exponent(2) - 3;
        exponentLSD  = exponentLSD - 3;
    end
end

if fixSigma
    numberDisplay(2) = numberDisplay(2) / 10;
    exponent(2) = exponent(2) + 1;
    exponentLSD  = exponentLSD + 1;
end

if exponent(2) >= 0
    numberDisplay(2) = numberDisplay(2) * 10^exponentLSD;
end

text = formatNumber(numberDisplay, exponent, exponentLSD, numberSign);
if outputFormat == 'm'
    text = [text, ' ', metricSymbol(exponentShift)];
else
    text = [text, exponentString(exponentShift, useTex)];
end

end



function exponentShift = calculateExponentShift(exponent, outputFormat)
switch outputFormat
    case 'n'
        exponentShift = 0;
    case 's'
        exponentShift = exponent(1);
    case {'e', 'm'}
        exponentShift = exponent(1) - mod(exponent(1), 3);
end
end

function text = formatNumber(numberDisplay, exponent, exponentLSD, numberSign)
formatCode = ['%.', num2str(max(0, -exponentLSD)), 'f'];
if numberSign == -1
    formatCode = ['-', formatCode];
end
datumString = sprintf(formatCode, numberDisplay(1));

formatCode = '%.0f';
if exponent(2) >= 0 && exponentLSD < 0
    formatCode = ['%.', num2str(-exponentLSD), 'f'];
end
sigmaString = sprintf(formatCode, numberDisplay(2));

text = [datumString, '(', sigmaString, ')'];
end

function symbol = metricSymbol(exponent)
metricNumberToSymbol = dictionary( ...
    -24:3:24, ...
    ["y", "z", "a", "f", "p", "n", "\mu", "m", "", "k", "M", "G", "T", "P", "E", "Z", "Y"] ...
    );

symbol = ['e', num2str(exponent)];
if metricNumberToSymbol.isKey(exponent)
    symbol = convertStringsToChars(metricNumberToSymbol(exponent));
end
end

function text = exponentString(exponentShift, useTex)
if exponentShift == 0
    text = '';
    return;
end

exponent_string = 'E';
if exponentShift > 0
    exponent_string = 'E+';
end
close_string = '';

if useTex
    exponent_string = '\times10^{';
    close_string = '}';
end

text = [exponent_string, num2str(exponentShift), close_string];
end