function [cancel, ims] = preprocessRegion(ims, preprocessor)
taskName = 'Preprocessing Region';
multiWaitbar(taskName, 0, 'CanCancel', 'on');
frameCount = size(ims, 3);

cancel = false;
proportionDelta = 1 / frameCount;
for index = 1:frameCount
    ims(:, :, index) = preprocessor.preprocess(ims(:, :, index));
    proportionComplete = index / frameCount;
    if mod(proportionComplete, 0.01) < proportionDelta
        cancel = multiWaitbar(taskName, proportionComplete);
    end
    if cancel
        break;
    end
end

multiWaitbar(taskName, 'Close');
end