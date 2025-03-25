classdef MovingAverage
    properties (Constant)
        bartlettHann = "Bartlett-Hann";
        bartlett = "Bartlett";
        blackman = "Blackman";
        blackmanHarris = "Blackman-Harris";
        bohman = "Bohman";
        chebyshev = "Chebyshev";
        flatTop = "Flat Top";
        gaussian = "Gaussian";
        hamming  = "Hamming";
        hann = "Hann";
        kaiser = "Kaiser";
        blackmanNuttall = "Blackman-Nuttall";
        parzen = "Parzen";
        rectangular = "Rectangular";
        tukey = "Tukey";
        triangular = "Triangular";

        keywords = sort([
            MovingAverage.bartlett, ...
            MovingAverage.bartlettHann, ...
            MovingAverage.blackman, ...
            MovingAverage.blackmanHarris, ...
            MovingAverage.blackmanNuttall, ...
            MovingAverage.bohman, ...
            MovingAverage.chebyshev, ...
            MovingAverage.flatTop, ...
            MovingAverage.gaussian, ...
            MovingAverage.hamming, ...
            MovingAverage.hann, ...
            MovingAverage.kaiser, ...
            MovingAverage.parzen, ...
            MovingAverage.rectangular, ...
            MovingAverage.triangular ...
            MovingAverage.tukey, ...
            ]);
    end

    methods (Static)
        function ma = averageByKeyword(x, windowSize, keyword)
            windowArray = MovingAverage.windowByKeyword(windowSize, keyword);
            ma = conv(x, windowArray, "same") / sum(windowArray);
        end
        function ma = averageByKeyword2(x, windowSize, keyword)
            window = MovingAverage.windowByKeyword(windowSize, keyword);
            ma = conv2(x, window, "same") / sum(window);
        end

        function windowArray = windowByKeyword(windowSize, keyword)
            switch keyword
                case MovingAverage.bartlettHann
                    windowArray = barthannwin(windowSize);
                case MovingAverage.bartlett
                    windowArray = bartlett(windowSize);
                case MovingAverage.blackman
                    windowArray = blackman(windowSize);
                case MovingAverage.blackmanHarris
                    windowArray = blackmanharris(windowSize);
                case MovingAverage.bohman
                    windowArray = bohmanwin(windowSize);
                case MovingAverage.chebyshev
                    windowArray = chebwin(windowSize);
                case MovingAverage.flatTop
                    windowArray = flattopwin(windowSize);
                case MovingAverage.gaussian
                    windowArray = gausswin(windowSize);
                case MovingAverage.hamming
                    windowArray = hamming(windowSize);
                case MovingAverage.hann
                    windowArray = hann(windowSize);
                case MovingAverage.kaiser
                    windowArray = kaiser(windowSize);
                case MovingAverage.blackmanNuttall
                    windowArray = nuttallwin(windowSize);
                case MovingAverage.parzen
                    windowArray = parzenwin(windowSize);
                case MovingAverage.rectangular
                    windowArray = rectwin(windowSize);
                case MovingAverage.tukey
                    windowArray = tukeywin(windowSize);
                case MovingAverage.triangular
                    windowArray = triang(windowSize);
            end
        end
        
        function adjacentName = getAdjacentName(windowName, distance)
            windowNames = MovingAverage.keywords;
            windowNameCount = numel(windowNames);
            windowIndex = find(windowNames == windowName, 1, "first");
            nextWindowIndex = AdjacentFloat.cyclic(1:windowNameCount, windowIndex, distance);
            adjacentName = windowNames(nextWindowIndex);
        end
        function nextWindowName = getNextName(windowName)
            nextWindowName = MovingAverage.getAdjacentName(windowName, 1);
        end
        function previousWindowName = getPreviousName(windowName)
            previousWindowName = MovingAverage.getAdjacentName(windowName, -1);
        end
    end
end