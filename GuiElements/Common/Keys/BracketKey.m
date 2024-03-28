classdef BracketKey    
    properties (Access = private, Constant)
        leftBracketKey = "leftbracket";
        rightBracketKey = "rightbracket";
        leftParenthesisKey = "9";
        rightParenthesisKey = "0";
    end
    
    methods (Static)
        function isBracketKey = is(key)
            isBracketKey = BracketKey.isLeftBracket(key) ...
                || BracketKey.isRightBracket(key) ...
                || BracketKey.isLeftParenthesis(key) ...
                || BracketKey.isRightParenthesis(key);
        end

        function is = isLeftBracket(key)
            is = strcmp(key, BracketKey.leftBracketKey);
        end
        function is = isRightBracket(key)
            is = strcmp(key, BracketKey.rightBracketKey);
        end
        function is = isLeftParenthesis(key)
            is = strcmp(key, BracketKey.leftParenthesisKey);
        end
        function is = isRightParenthesis(key)
            is = strcmp(key, BracketKey.rightParenthesisKey);
        end

        function is = isBracket(key)
            is = BracketKey.isLeftBracket(key) ...
                || BracketKey.isRightBracket(key);
        end
        function is = isParenthesis(key)
            is = BracketKey.isLeftParenthesis(key) ...
                || BracketKey.isRightParenthesis(key);
        end
        function is = isLeft(key)
            is = BracketKey.isLeftBracket(key) ...
                || BracketKey.isLeftParenthesis(key);
        end
        function is = isRight(key)
            is = BracketKey.isRightBracket(key) ...
                || BracketKey.isRightParenthesis(key);
        end
    end
end

