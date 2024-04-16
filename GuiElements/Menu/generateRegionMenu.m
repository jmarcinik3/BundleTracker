function generateRegionMenu(fig, trackingLinker)
m = uimenu(fig, "Text", "Region");
generateThresholdMenu(m, trackingLinker);
generateBlobDetectionMenu(m, trackingLinker);
generateResetMenu(m, trackingLinker);
end

function generateBlobDetectionMenu(parentMenu, trackingLinker)
text = SettingsParser.getBlobDetectionFigureDefaults().Name;
uimenu(parentMenu, ...
    "Text", text, ...
    "MenuSelectedFcn", @trackingLinker.blobDetectionButtonPushed ...
    );
end

function generateResetMenu(parentMenu, trackingLinker)
resetKeywords = RegionUserData.keywords;
text = SettingsParser.getResetRegionLabel();
m = uimenu(parentMenu, "Text", text);

for index = 1:numel(resetKeywords)
    resetKeyword = resetKeywords(index);
    uimenu(m, ...
        "Text", resetKeyword, ...
        "MenuSelectedFcn", @trackingLinker.resetRegionsButtonPushed, ...
        "UserData", resetKeyword ...
        );
end
end

function generateThresholdMenu(parentMenu, trackingLinker)
text = SettingsParser.getAutothresholdFigureDefaults().Name;
uimenu(parentMenu, ...
    "Text", text, ...
    "MenuSelectedFcn", @trackingLinker.regionThresholdButtonPushed ...
    );
end
