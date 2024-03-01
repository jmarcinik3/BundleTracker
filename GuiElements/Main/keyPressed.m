function keyPressed(trackingLinker, source, event)
activeRegion = trackingLinker.getActiveRegion();
directorySelector = trackingLinker.getDirectorySelector();

key = event.Key;
modifiers = event.Modifier;
modKey = ModifierKey(modifiers);

if objectExists(activeRegion) && RegionAdjustKey.is(key)
    if modKey.isCtrlShiftAlt && ArrowKey.isVertical(key)
        RegionOrderer.byKey(activeRegion, event);
    elseif modKey.isPureAlt
        if ArrowKey.isVertical(key)
            RegionOrderer.byKey(activeRegion, event);
        elseif ArrowKey.isLeft(key)
            trackingLinker.setPreviousRegionVisible();
        elseif ArrowKey.isRight(key)
            trackingLinker.setNextRegionVisible();
        end
    elseif modKey.hasZeroModifiers
        RegionMover.byKey(activeRegion, event);
    elseif modKey.isPureCtrl
        if RegionAdjustKey.isStandard(key)
            RegionCompressor.byKey(activeRegion, event);
        elseif RegionAdjustKey.isDelete(key)
            RegionMover.byKey(activeRegion, event);
        end
    elseif modKey.isPureCtrlShift
        RegionExpander.byKey(activeRegion, event);
    end
elseif modKey.isPureCtrl
    if strcmp(key, "i")
        directorySelector.chooseDirectory(source, event);
    elseif strcmp(key, "o")
        directorySelector.openDirectory();
    elseif strcmp(key, "s")
        trackingLinker.exportImageIfPossible(source, event);
    elseif strcmp(key, "return")
        trackingLinker.trackButtonPushed(source, event)
    end
end
end



function exists = objectExists(obj)
exists = isobject(obj) && isvalid(obj);
end