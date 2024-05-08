classdef AdjacentFloat
    methods (Static)
        function adjacentFloat = cyclic(array, number, distance)
            adjacentFloat = getAdjacentFloatCyclic(array, number, distance);
        end
        function nextFloat = cyclicNext(array, number)
            nextFloat = getAdjacentFloatCyclic(array, number, 1);
        end
        function previousFloat = cyclicPrevious(array, number)
            previousFloat = getAdjacentFloatCyclic(array, number, -1);
        end

        function adjacentFloat = bounded(array, number, distance)
            adjacentFloat = getAdjacentFloatBounded(array, number, distance);
        end
        function nextFloat = boundedNext(array, number)
            nextFloat = getAdjacentFloatBounded(array, number, 1);
        end
        function previousFloat = boundedPrevious(array, number)
            previousFloat = getAdjacentFloatBounded(array, number, -1);
        end
    end
end



function adjacentFloat = getAdjacentFloatCyclic(array, number, distance)
array = sort(array);
arraySize = numel(array);
numberIndex = find(array == number);
nextIndex = mod(numberIndex + distance, arraySize);
if nextIndex == 0
    nextIndex = arraySize;
end
adjacentFloat = array(nextIndex);
end

function adjacentFloat = getAdjacentFloatBounded(array, number, distance)
array = sort(array);
arraySize = numel(array);
numberIndex = find(array == number);
nextIndex = numberIndex + distance;
if nextIndex < 1
    nextIndex = arraySize;
elseif nextIndex > arraySize
    nextIndex = 1;
end
adjacentFloat = array(nextIndex);
end
