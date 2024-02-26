function keyPressed(trackingGui, ~, event)
currentRegion = trackingGui.getCurrentRegion();
key = event.Key;

if  objectExists(currentRegion) && RegionAdjustKey.is(key)
    modifiers = event.Modifier;
    modifierAnalyzer = KeyModifierAnalyzer(modifiers);

    if modifierAnalyzer.hasAlt
        RegionOrderer.byKey(currentRegion, key, modifiers);
    elseif modifierAnalyzer.hasPureAlt
        switchRegion(key, trackingGui);
    else
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
modifierAnalyzer = KeyModifierAnalyzer(modifiers);
if modifierAnalyzer.hasCtrlShiftAlt && ArrowKey.isUp(key)
    bringToFront(region);
elseif modifierAnalyzer.hasZeroModifiers
    RegionMover.byKey(region, key);
elseif modifierAnalyzer.hasPureCtrl
    RegionCompressor.byKey(region, key);
elseif modifierAnalyzer.hasPureCtrlShift
    RegionExpander.byKey(region, key);
end
end

function exists = objectExists(obj)
exists = isobject(obj) && isvalid(obj);
end