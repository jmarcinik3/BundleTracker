function keyPressed(trackingGui, ~, event)
currentRegion = trackingGui.getCurrentRegion();
key = event.Key;

if objectExists(currentRegion) && RegionAdjustKey.is(key)
    modifiers = event.Modifier;
    configureRegion(currentRegion, key, modifiers)
end
end



function configureRegion(region, key, modifiers)
isUnmodified = numel(modifiers) == 0;
hasShift = any(ismember(modifiers, "shift"));
hasCtrl = any(ismember(modifiers, "control"));
hasAlt = any(ismember(modifiers, "alt"));

hasPureCtrl = hasCtrl && ~hasShift && ~hasAlt;
hasPureCtrlShift = hasCtrl && hasShift && ~hasAlt;
hasCtrlShiftAlt = hasCtrl && hasShift && hasAlt;

if hasCtrlShiftAlt && ArrowKey.isUp(key)
    bringToFront(region);
elseif isUnmodified
    RegionMover.byKey(region, key);
elseif hasPureCtrl
    RegionCompressor.byKey(region, key);
elseif hasPureCtrlShift
    RegionExpander.byKey(region, key);
end
end

function exists = objectExists(obj)
exists = isobject(obj) && isvalid(obj);
end