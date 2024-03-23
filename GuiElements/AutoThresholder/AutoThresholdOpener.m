classdef AutoThresholdOpener
    methods (Static)
        function thresholdRanges = byKeyword(fig, regionalImages, keyword)
            thresholdFcn = Threshold.handleByKeyword(keyword);
            thresholdRanges = AutoThresholdLinker.openGui(fig, regionalImages, thresholdFcn);
        end
    end
end
