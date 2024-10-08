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
            regionUserData = RegionUserData.configureByRegion(preUserData, postUserData);
        end
    end
end
