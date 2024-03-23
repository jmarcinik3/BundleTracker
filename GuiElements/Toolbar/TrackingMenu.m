function TrackingMenu(fig, trackingLinker)
m = uimenu(fig, "Text", "Region");
generateRegionMenu(m, trackingLinker);
end



function generateRegionMenu(m, trackingLinker)
uimenu(m, ...
    "Text", BlobDetectorGui.title, ...
    "MenuSelectedFcn", @trackingLinker.blobDetectionButtonPushed ...
    );

generateThresholdsMenu(m, trackingLinker);
generateThresholdMenu(m, trackingLinker);
generateResetMenu(m, trackingLinker);
end


function generateResetMenu(parentMenu, trackingLinker)
resetKeywords = RegionUserData.keywords;
m = uimenu(parentMenu, "Text", RegionPreviewer.resetTitle);
for index = 1:numel(resetKeywords)
    resetKeyword = resetKeywords(index);
    uimenu(m, ...
        "Text", resetKeyword, ...
        "MenuSelectedFcn", @trackingLinker.resetRegionsButtonPushed, ...
        "UserData", resetKeyword ...
        );
end
end

function generateThresholdsMenu(parentMenu, trackingLinker)
uimenu(parentMenu, ...
    "Text", OtsuThresholdsGui.title, ...
    "MenuSelectedFcn", @trackingLinker.otsuThresholdsPushed ...
    );
end

function generateThresholdMenu(parentMenu, trackingLinker)
m = uimenu(parentMenu, "Text", "Binary Autothreshold");
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
