function keyPressed(trackingLinker, source, event)
activeRegion = trackingLinker.getActiveRegion();
key = event.Key;
modKey = ModifierKey(event);

if objectExists(activeRegion) && RegionAdjustKey.is(key)
    if modKey.isCtrlShiftAlt
        if ArrowKey.isVertical(key)
            RegionOrderer.byKey(activeRegion, event);
        elseif RegionAdjustKey.isDelete(key)
            trackingLinker.clearRegions();
        end
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
    % if strcmp(key, "i")
    %     trackingLinker.importVideo(source, event);
    % elseif strcmp(key, "o")
    %     trackingLinker.openDirectory();
    % elseif strcmp(key, "s")
    %     trackingLinker.exportImageIfPossible(source, event);
    if strcmp(key, "return")
        trackingLinker.trackButtonPushed(source, event)
    end
end
end



function exists = objectExists(obj)
exists = isobject(obj) && isvalid(obj);
end
