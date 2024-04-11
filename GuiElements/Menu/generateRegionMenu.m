function generateRegionMenu(fig, trackingLinker)
m = uimenu(fig, "Text", "Region");
generateBlobDetectionMenu(m, trackingLinker);
generateThresholdMenu(m, trackingLinker);
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
m = uimenu(parentMenu, "Text", "Autothreshold");
thresholdKeywords = Threshold.keywords;
for index = 1:numel(thresholdKeywords)
    thresholdKeyword = thresholdKeywords(index);
    uimenu(m, ...
        "Text", thresholdKeyword, ...
        "MenuSelectedFcn", @trackingLinker.regionThresholdButtonPushed, ...
        "UserData", thresholdKeyword ...
        );
end
end
