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

        keywords = [
            MovingAverage.bartlettHann, ...
            MovingAverage.bartlett, ...
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
            ]
    end

    methods (Static)
        function ma = averageByKeyword(x, windowSize, keyword)
            window = MovingAverage.windowByKeyword(windowSize, keyword);
            ma = conv(x, window, "same") / sum(window);
        end

        function window = windowByKeyword(windowSize, keyword)
            switch (keyword)
                case MovingAverage.bartlettHann
                    window = barthannwin(windowSize);
                case MovingAverage.bartlett
                    window = bartlett(windowSize);
                case MovingAverage.blackman
                    window = blackman(windowSize);
                case MovingAverage.blackmanHarris
                    window = blackmanharris(windowSize);
                case MovingAverage.bohman
                    window = bohmanwin(windowSize);
                case MovingAverage.chebyshev
                    window = chebwin(windowSize);
                case MovingAverage.flatTop
                    window = flattopwin(windowSize);
                case MovingAverage.gaussian
                    window = gausswin(windowSize);
                case MovingAverage.hamming
                    window = hamming(windowSize);
                case MovingAverage.hann
                    window = hann(windowSize);
                case MovingAverage.kaiser
                    window = kaiser(windowSize);
                case MovingAverage.blackmanNuttall
                    window = nuttallwin(windowSize);
                case MovingAverage.parzen
                    window = parzenwin(windowSize);
                case MovingAverage.rectangular
                    window = rectwin(windowSize);
                case MovingAverage.tukey
                    window = tukeywin(windowSize);
                case MovingAverage.triangular
                    window = triang(windowSize);
            end
        end
    end
end