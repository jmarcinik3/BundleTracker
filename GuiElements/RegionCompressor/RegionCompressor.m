classdef RegionCompressor
    properties (Access = private)
        region;
    end

    methods
        function obj = RegionCompressor(region)
            obj.region = region;
        end
    end

    %% Functions to compress or delete region
    methods (Static)
        function byKey(region, key)
            regionCompressor = RegionCompressor(region);
            if ArrowKey.isUp(key)
                regionCompressor.compressUp();
            elseif ArrowKey.isLeft(key)
                regionCompressor.compressLeft();
            elseif ArrowKey.isDown(key)
                regionCompressor.compressDown();
            elseif ArrowKey.isRight(key)
                regionCompressor.compressRight();
            end
        end
    end

    methods
        function compressUp(obj, ~, ~)
            region = obj.region;
            compressUp(region);
            region.notify("ROIMoved");
        end
        function compressDown(obj, ~, ~)
            region = obj.region;
            compressDown(region);
            region.notify("ROIMoved");
        end
        function compressLeft(obj, ~, ~)
            region = obj.region;
            compressLeft(region);
            region.notify("ROIMoved");
        end
        function compressRight(obj, ~, ~)
            region = obj.region;
            compressRight(region);
            region.notify("ROIMoved");
        end

        function compressIn(obj, ~, ~)
            region = obj.region;
            compressIn(region);
            region.notify("ROIMoved");
        end

        function compressUpLeft(obj, ~, ~)
            region = obj.region;
            compressUpLeft(region);
            region.notify("ROIMoved");
        end
        function compressUpRight(obj, ~, ~)
            region = obj.region;
            compressUpRight(region);
            region.notify("ROIMoved");
        end
        function compressDownLeft(obj, ~, ~)
            region = obj.region;
            compressDownLeft(region);
            region.notify("ROIMoved");
        end
        function compressDownRight(obj, ~, ~)
            region = obj.region;
            compressDownRight(region);
            region.notify("ROIMoved");
        end
    end
end



function compressUp(region)
position = get(region, "Position");
position(4) = position(4) - 1;
set(region, "Position", position);
end
function compressDown(region)
position = get(region, "Position");
position(2) = position(2) + 1;
position(4) = position(4) - 1;
set(region, "Position", position);
end
function compressLeft(region)
position = get(region, "Position");
position(3) = position(3) - 1;
set(region, "Position", position);
end
function compressRight(region)
position = get(region, "Position");
position(1) = position(1) + 1;
position(3) = position(3) - 1;
set(region, "Position", position);
end

function compressUpLeft(region)
compressUp(region);
compressLeft(region);
end
function compressUpRight(region)
compressUp(region);
compressRight(region);
end
function compressDownLeft(region)
compressDown(region);
compressLeft(region);
end
function compressDownRight(region)
compressDown(region);
compressRight(region);
end

function compressIn(region)
compressUp(region);
compressDown(region);
compressLeft(region);
compressRight(region);
end