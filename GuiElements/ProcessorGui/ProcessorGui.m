classdef ProcessorGui < PreprocessorGui & PostprocessorGui
    methods
        function obj = ProcessorGui(gl)
            obj@PreprocessorGui(gl);
            obj@PostprocessorGui(gl);
        end
    end

    %% Functions to retreive GUI elements and state information
    methods
        function gl = getGridLayout(obj)
            gl = getGridLayout@PreprocessorGui(obj);
        end
        function regionUserData = getRegionUserData(obj)
            preUserData = getRegionUserData@PreprocessorGui(obj);
            postUserData = getRegionUserData@PostprocessorGui(obj);

            thresholds = preUserData.getThresholds();
            invert = preUserData.getInvert();
            trackingMode = postUserData.getTrackingMode();
            angleMode = postUserData.getAngleMode();
            positiveDirection = postUserData.getPositiveDirection();

            regionUserData = RegionUserData();
            regionUserData.setThresholds(thresholds);
            regionUserData.setInvert(invert);
            regionUserData.setTrackingMode(trackingMode);
            regionUserData.setAngleMode(angleMode);
            regionUserData.setPositiveDirection(positiveDirection);
        end
    end
end
