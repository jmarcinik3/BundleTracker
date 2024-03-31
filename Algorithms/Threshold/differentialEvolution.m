function parameters = differentialEvolution(binCounts, evolverLength, func, varargin)
p = inputParser;
addOptional(p, "CrossoverProbability", 0.1);
addOptional(p, "MinimumValue", 0);
addOptional(p, "MaximumValue", find(binCounts, 1, "last"));
addOptional(p, "PopulationSize", 12 * evolverLength);
addOptional(p, "RunCount", 1);
addOptional(p, "Tolerance", 1e-5);
addOptional(p, "WeightFactor", 0.5);
parse(p, varargin{:});
crossoverProbability = 1 - p.Results.CrossoverProbability;
maxValue = p.Results.MaximumValue;
minValue = p.Results.MinimumValue;
populationSize = p.Results.PopulationSize;
runCount = p.Results.RunCount;
iterationTolerance = p.Results.Tolerance;
weightFactor = p.Results.WeightFactor;

bestParents = zeros(runCount, evolverLength);

for runIndex = 1:runCount
    x = round(minValue + (maxValue - minValue) * rand(populationSize, evolverLength));
    x = sort(x, 2);
    v = zeros(size(x));

    fitnessParent = zeros(1, populationSize);
    for populationIndex = 1:populationSize
        fitnessParent(populationIndex) = func(x(populationIndex, :), binCounts);
    end
    fitnessChild = fitnessParent;
    previousParents = fitnessParent;
    parentDifference = 1;

    while parentDifference > iterationTolerance
        for populationIndex = 1:populationSize
            i1 = generateRandomIndex(populationSize);
            i2 = generateRandomIndex(populationSize);
            i3 = generateRandomIndex(populationSize);
            while i1 == i2
                i2 = generateRandomIndex(populationSize);
            end
            while i2 == i3
                i3 = generateRandomIndex(populationSize);
            end
            v(populationIndex, :) = x(i1, :) + weightFactor * (x(i2, :) - x(i3, :));
        end

        u = x;
        crossoverIndices = generateRandomIndex(evolverLength, [populationSize, 1]);
        crossoverWins = rand(populationSize, evolverLength) > crossoverProbability;
        crossoverWins(crossoverIndices, :) = true;
        u(~crossoverWins) = round(v(~crossoverWins));
        u(u < minValue) = minValue;
        u(u > maxValue) = maxValue;
        u = sort(u, 2);

        for populationIndex = 1:populationSize
            fitnessChild(populationIndex) = func(u(populationIndex, :), binCounts);
        end

        parentLessThanChild = fitnessParent < fitnessChild;
        fitnessParent(parentLessThanChild) = fitnessChild(parentLessThanChild);
        x(parentLessThanChild, :) = u(parentLessThanChild, :);

        [~, bestParentIndex] = max(fitnessParent);
        bestParent = x(bestParentIndex, :);
        parentDifference = mean(abs(1 - previousParents / fitnessParent));
        previousParents = fitnessParent;
    end

    bestParents(runIndex, :) = bestParent;
end

parameters = median(bestParents, 1);
end



function x = generateRandomIndex(maxIndex, randomSize)
if nargin < 2
    xRandom = rand;
else
    xRandom = rand(randomSize);
end
x = round(xRandom * (maxIndex - 1)) + 1;
end
