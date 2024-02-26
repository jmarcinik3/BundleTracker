function keyPressed(trackingGui, ~, event)
currentRegion = trackingGui.getCurrentRegion();
key = event.Key;

if  RegionAdjustKey.is(key)
    modifiers = event.Modifier;

    hasAlt = any(ismember(modifiers, "alt"));
    modifierCount = numel(modifiers);
    hasOneModifier = modifierCount == 1;
    hasPureAlt = hasAlt && hasOneModifier;

    if hasPureAlt
        switchRegion(key, trackingGui);
    elseif objectExists(currentRegion)
        configureRegion(currentRegion, key, modifiers) ;
    end
end
end


function switchRegion(key, trackingGui)
if ArrowKey.isLeft(key)
    trackingGui.setPreviousRegionVisible();
elseif ArrowKey.isRight(key)
    trackingGui.setNextRegionVisible();
end
end


function configureRegion(region, key, modifiers)
modifierCount = numel(modifiers);
isUnmodified = modifierCount == 0;
hasOneModifier = modifierCount == 1;
hasTwoModifiers = modifierCount == 2;

hasShift = any(ismember(modifiers, "shift"));
hasCtrl = any(ismember(modifiers, "control"));
hasAlt = any(ismember(modifiers, "alt"));

hasPureCtrl = hasCtrl && hasOneModifier;
hasPureCtrlShift = hasCtrl && hasShift && hasTwoModifiers;
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