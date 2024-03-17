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
        function userData = getRegionUserData(obj)
            preUserData = getRegionUserData@PreprocessorGui(obj);
            postUserData = getRegionUserData@PostprocessorGui(obj);
            userData = table2struct([ ...
                struct2table(preUserData), ...
                struct2table(postUserData) ...
                ]);
        end
    end
end
