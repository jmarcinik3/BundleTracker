classdef DetrendAlgorithms
    properties (Constant)
        keywords = [ ...
            DetrendAlgorithms.noneKeyword, ...
            DetrendAlgorithms.autoKeyword, ...
            sort([ ...
            DetrendAlgorithms.highPassKeyword, ...
            DetrendAlgorithms.movingAverageKeyword, ...
            DetrendAlgorithms.polyKeyword ...
            ]) ...
            ];
    end
    properties (Constant, Access = private)
        noneKeyword = "None";
        autoKeyword = "Auto";
        highPassKeyword = "High-Pass Filter";
        movingAverageKeyword = "Moving Average";
        polyKeyword = "Polynomial Regression";
    end


    methods (Static)
        function [x, y, detrendInfo] = byKeyword(x, y, keyword)
            switch keyword
                case DetrendAlgorithms.noneKeyword
                    [x, y, detrendInfo] = DetrendAlgorithms.byNone(x, y);
                case DetrendAlgorithms.autoKeyword
                    [x, y, detrendInfo] = DetrendAlgorithms.byAuto(x, y);
                    case DetrendAlgorithms.highPassKeyword
                    [x, y, detrendInfo] = DetrendAlgorithms.byHighPassFilter(x, y);
                case DetrendAlgorithms.movingAverageKeyword
                    [x, y, detrendInfo] = DetrendAlgorithms.byMovingAverage(x, y);
                case DetrendAlgorithms.polyKeyword
                    [x, y, detrendInfo] = DetrendAlgorithms.byPolyFit(x, y);
            end
        end
        function is = isIdentity(keyword)
            is = strcmp(DetrendAlgorithms.noneKeyword, keyword);
        end

        function [x, y, detrendInfo] = byNone(x, y)
            detrendInfo = [];
        end
        function [x, y, detrendInfo] = byAuto(x, y)
            [x, y, detrendInfo] = byAuto(x, y);
        end
        function [x, y, detrendInfo] = byHighPassFilter(x, y)
            [x, y, detrendInfo] = byHighPassFilter(x, y);
        end
        function [x, y, detrendInfo] = byMovingAverage(x, y)
            [x, y, detrendInfo] = byMovingAverage(x, y);
        end
        function [x, y, detrendInfo] = byPolyFit(x, y)
            [x, y, detrendInfo] = byPolyFit(x, y);
        end
    end
end



function [x, y, info] = byAuto(x, y)
xSize = numel(x);

xDetrender = Detrender(1:xSize, x);
xDetrender.detrend();
x = xDetrender.getDetrended();

yDetrender = Detrender(1:xSize, y);
yDetrender.detrend();
y = yDetrender.getDetrended();

info = struct( ...
    "x", xDetrender.getInfo(), ...
    "y", yDetrender.getInfo() ...
    );
end

function [x, y, info] = byMovingAverage(x, y)
xSize = numel(x);

xDetrender = Detrender(1:xSize, x);
xDetrender.byMovingAverage();
x = xDetrender.getDetrended();

yDetrender = Detrender(1:xSize, y);
yDetrender.byMovingAverage();
y = yDetrender.getDetrended();

info = struct( ...
    "x", xDetrender.getInfo(), ...
    "y", yDetrender.getInfo() ...
    );
end

function [x, y, info] = byPolyFit(x, y)
xSize = numel(x);

xDetrender = Detrender(1:xSize, x);
xDetrender.byPolynomial();
x = xDetrender.getDetrended();

yDetrender = Detrender(1:xSize, y);
yDetrender.byPolynomial();
y = yDetrender.getDetrended();

info = struct( ...
    "x", xDetrender.getInfo(), ...
    "y", yDetrender.getInfo() ...
    );
end
