function keyPressed(trackingLinker, source, event)
activeRegion = trackingLinker.getActiveRegion();
key = event.Key;
modKey = ModifierKey(event);

if objectExists(activeRegion)
    if modKey.hasZeroModifiers
        RegionMover.byKey(activeRegion, event);
    elseif modKey.isPureAlt
        if BracketKey.isLeftBracket(key)
            trackingLinker.setPreviousRegionVisible();
        elseif BracketKey.isRightBracket(key)
            trackingLinker.setNextRegionVisible();
        end
    elseif modKey.isPureCtrl
        if RegionAdjustKey.isStandard(key)
            RegionCompressor.byKey(activeRegion, event);
        elseif RegionAdjustKey.isDelete(key)
            RegionMover.byKey(activeRegion, event);
        elseif BracketKey.isBracket(key)
            RegionOrderer.byKey(activeRegion, event);
        end
    elseif modKey.isPureCtrlShift
        RegionExpander.byKey(activeRegion, event);
        if BracketKey.isBracket(key)
            RegionOrderer.byKey(activeRegion, event);
        elseif RegionAdjustKey.isDelete(key)
            trackingLinker.clearRegions();
        end
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
