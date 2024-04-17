classdef Threshold
    properties (Constant)
        crossEntropyKeyword = "Minimum Cross Entropy";
        fuzzyEntropyKeyword = "Minimum Fuzzy Entropy"
        johannsonBilleKeyword = "Johannsen-Bille Method";
        kapurSahooWongKeyword = "Kapur-Sahoo-Wong Method"
        kittlerIllingworthKeyword = "Kittler-Illingworth Thresholding";
        otsuKeyword = "Otsu's Method";
        ridlerCalvardKeyword = "Ridler-Calvard Method";
        triangleKeyword = "Triangle Method";
        yanniHorneKeyword = "Yanni-Horne";
        yenChangChangKeyword = "Yen-Change-Change";
        keywords = sort([ ...
            Threshold.crossEntropyKeyword, ...
            Threshold.fuzzyEntropyKeyword, ...
            Threshold.johannsonBilleKeyword, ...
            Threshold.kapurSahooWongKeyword, ...
            Threshold.kittlerIllingworthKeyword, ...
            Threshold.otsuKeyword, ...
            Threshold.ridlerCalvardKeyword, ...
            Threshold.triangleKeyword, ...
            Threshold.yanniHorneKeyword, ...
            Threshold.yenChangChangKeyword ...
            ]);
    end

    methods (Static)
        function thresholdFcn = handleByKeyword(keyword)
            switch keyword
                case Threshold.crossEntropyKeyword
                    thresholdFcn = @Threshold.byMinimumCrossEntropy;
                case Threshold.fuzzyEntropyKeyword
                    thresholdFcn = @Threshold.byFuzzyEntropy;
                case Threshold.johannsonBilleKeyword
                    thresholdFcn = @Threshold.byJohannsenBille;
                case Threshold.kapurSahooWongKeyword
                    thresholdFcn = @Threshold.byKapurSahooWong;
                case Threshold.kittlerIllingworthKeyword
                    thresholdFcn = @Threshold.byKittlerIllingworth;
                case Threshold.otsuKeyword
                    thresholdFcn = @Threshold.byOtsu;
                case Threshold.ridlerCalvardKeyword
                    thresholdFcn = @Threshold.byRidlerCalvard;
                case Threshold.triangleKeyword
                    thresholdFcn = @Threshold.byTriangle;
                case Threshold.yanniHorneKeyword
                    thresholdFcn = @Threshold.byYanniHorne;
                case Threshold.yenChangChangKeyword
                    thresholdFcn = @Threshold.byYenChangChang;
            end
        end

        function threshold = byFuzzyEntropy(im)
            threshold = fuzzyEntropy(im, 1, "RunCount", 3);
            threshold = Threshold.im2(threshold, class(im));
        end
        function threshold = byJohannsenBille(im)
            threshold = Threshold.im2(johannsenBille(im), class(im));
        end
        function threshold = byKapurSahooWong(im)
            threshold = Threshold.im2(kapurSahooWong(im), class(im));
        end
        function threshold = byKittlerIllingworth(im)
            threshold = kittlerIllingworth(im);
        end
        function threshold = byMinimumCrossEntropy(im)
            threshold = Threshold.im2(minimumCrossEntropy(im), class(im));
        end
        function threshold = byOtsu(im)
            threshold = Threshold.im2(graythresh(im), class(im));
        end
        function threshold = byRidlerCalvard(im)
            threshold = ridlerCalvard(im);
        end
        function threshold = byTriangle(im)
            threshold = Threshold.im2(triangleThreshold(im), class(im));
        end
        function threshold = byYanniHorne(im)
            threshold = Threshold.im2(yanniHorne(im), class(im));
        end
        function threshold = byYenChangChang(im)
            threshold = Threshold.im2(yenChangChang(im), class(im));
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
