function keyPressed(trackingGui, ~, event)
currentRegion = trackingGui.getCurrentRegion();
key = event.Key;

if  objectExists(currentRegion) && RegionAdjustKey.is(key)
    modifiers = event.Modifier;
    modKey = ModifierKey(modifiers);

    if modKey.isCtrlShiftAlt && ArrowKey.isVertical(key)
        RegionOrderer.byKey(currentRegion, event);
    elseif modKey.isPureAlt
        if ArrowKey.isVertical(key)
            RegionOrderer.byKey(currentRegion, event);
        elseif ArrowKey.isHorizontal(key)
            switchRegion(key, trackingGui);
        end
    elseif modKey.hasZeroModifiers
        RegionMover.byKey(currentRegion, event);
    elseif modKey.isPureCtrl
        if RegionAdjustKey.isStandard(key)
            RegionCompressor.byKey(currentRegion, event);
        elseif RegionAdjustKey.isDelete(key)
            RegionMover.byKey(currentRegion, event);
        end
    elseif modKey.isPureCtrlShift
        RegionExpander.byKey(currentRegion, event);
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



function exists = objectExists(obj)
exists = isobject(obj) && isvalid(obj);
end