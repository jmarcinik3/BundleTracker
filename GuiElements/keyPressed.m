function keyPressed(trackingGui, source, event)
currentRegion = trackingGui.getCurrentRegion();
key = event.Key;
modifiers = event.Modifier;
modKey = ModifierKey(modifiers);

if  objectExists(currentRegion) && RegionAdjustKey.is(key)
    if modKey.isCtrlShiftAlt && ArrowKey.isVertical(key)
        RegionOrderer.byKey(currentRegion, event);
    elseif modKey.isPureAlt
        if ArrowKey.isVertical(key)
            RegionOrderer.byKey(currentRegion, event);
        elseif ArrowKey.isLeft(key)
            trackingGui.setPreviousRegionVisible();
        elseif ArrowKey.isRight(key)
            trackingGui.setNextRegionVisible();
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
elseif modKey.isPureCtrl
    if strcmp(key, "i")
        trackingGui.chooseDirectory(source, event);
    elseif strcmp(key, "o")
        trackingGui.openDirectory();
    elseif strcmp(key, "s")
        trackingGui.exportImageIfPossible(source, event);
    elseif strcmp(key, "return")
        trackingGui.trackButtonPushed(source, event)
    end
end
end



function exists = objectExists(obj)
exists = isobject(obj) && isvalid(obj);
end