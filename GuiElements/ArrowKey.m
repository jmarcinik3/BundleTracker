classdef ArrowKey    
    properties (Access = private, Constant)
        upKey = "uparrow";
        leftKey = "leftarrow";
        downKey = "downarrow";
        rightKey = "rightarrow";
    end
    
    methods (Static)
        function isArrowKey = is(key)
            isArrowKey = ArrowKey.isUp(key) ...
                || ArrowKey.isLeft(key) ...
                || ArrowKey.isDown(key) ...
                || ArrowKey.isRight(key);
        end

        function is = isUp(key)
            is = strcmp(key, ArrowKey.upKey);
        end
        function is = isLeft(key)
            is = strcmp(key, ArrowKey.leftKey);
        end
        function is = isDown(key)
            is = strcmp(key, ArrowKey.downKey);
        end
        function is = isRight(key)
            is = strcmp(key, ArrowKey.rightKey);
        end
    end
end

