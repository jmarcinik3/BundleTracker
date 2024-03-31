classdef Threshold
    properties (Constant)
        otsuKeyword = "Otsu's Method";
        ridlerCalvardKeyword = "Ridler-Calvard Method";
        kittlerIllingworthKeyword = "Kittler-Illingworth Thresholding";
        crossEntropyKeyword = "Minimum Cross Entropy";
        fuzzyEntropyKeyword = "Minimum Fuzzy Entropy"
        triangleKeyword = "Triangle Method";
        keywords = sort([ ...
            Threshold.otsuKeyword, ...
            Threshold.ridlerCalvardKeyword, ...
            Threshold.kittlerIllingworthKeyword, ...
            Threshold.crossEntropyKeyword, ...
            Threshold.fuzzyEntropyKeyword, ...
            Threshold.triangleKeyword ...
            ]);
    end

    methods (Static)
        function thresholdFcn = handleByKeyword(keyword)
            switch keyword
                case Threshold.otsuKeyword
                    thresholdFcn = @Threshold.byOtsu;
                case Threshold.ridlerCalvardKeyword
                    thresholdFcn = @Threshold.byRidlerCalvard;
                case Threshold.kittlerIllingworthKeyword
                    thresholdFcn = @Threshold.byKittlerIllingworth;
                case Threshold.crossEntropyKeyword
                    thresholdFcn = @Threshold.byMinimumCrossEntropy;
                case Threshold.fuzzyEntropyKeyword
                    thresholdFcn = @Threshold.byFuzzyEntropy;
                case Threshold.triangleKeyword
                    thresholdFcn = @Threshold.byTriangle;
            end
        end

        function threshold = byOtsu(im)
            threshold = Threshold.im2(graythresh(im), class(im));
        end

        function threshold = byRidlerCalvard(im)
            threshold = ridlerCalvard(im);
        end

        function threshold = byKittlerIllingworth(im)
            threshold = kittlerIllingworth(im);
        end

        function threshold = byFuzzyEntropy(im)
            threshold = fuzzyEntropy(im, 1, "RunCount", 3);
            threshold = Threshold.im2(threshold, class(im));
        end

        function threshold = byMinimumCrossEntropy(im)
            threshold = Threshold.im2(minimumCrossEntropy(im), class(im));
        end

        function threshold = byTriangle(im)
            threshold = Threshold.im2(triangleThreshold(im), class(im));
        end

        function im = im2(im, toClass)
            im = imageToClass(im, toClass);
        end
    end
end


function im = imageToClass(im, toClass)
switch toClass
    case "uint8"
        im = im2uint8(im);
    case "uint16"
        im = im2uint16(im);
    case "single"
        im = im2single(im);
    case "double"
        im = im2double(im);
end
end
