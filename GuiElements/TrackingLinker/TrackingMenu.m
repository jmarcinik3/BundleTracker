function TrackingMenu(fig, trackingLinker)
generateFileMenu(fig, trackingLinker);
generateRegionMenu(fig, trackingLinker);
generatePlottingMenu(fig, trackingLinker);
end

function generateFileMenu(fig, trackingLinker)
m = uimenu(fig, "Text", "File");
generateSaveImageMenu(m, trackingLinker);
generateImportRegionMenu(m, trackingLinker);
generateImportVideoMenu(m, trackingLinker);
generateOpenDirectoryMenu(m, trackingLinker);
end
function generateImportRegionMenu(parentMenu, trackingLinker)
uimenu(parentMenu, ...
    "Text", SettingsParser.getImportRegionsLabel(), ...
    "MenuSelectedFcn", @trackingLinker.importRegionsMenuCalled, ...
    "Accelerator", "R" ...
    );
end
function generateSaveImageMenu(parentMenu, trackingLinker)
uimenu(parentMenu, ...
    "Text", SettingsParser.getExportAxisLabel(), ...
    "MenuSelectedFcn", @trackingLinker.exportImageButtonPushed, ...
    "Accelerator", "S" ...
    );
end
function generateImportVideoMenu(parentMenu, videoSelector)
uimenu(parentMenu, ...
    "Text", SettingsParser.getImportVideoLabel(), ...
    "MenuSelectedFcn", @videoSelector.importVideo, ...
    "Accelerator", "I" ...
    );
end
function generateOpenDirectoryMenu(parentMenu, videoSelector)
uimenu(parentMenu, ...
    "Text", SettingsParser.getOpenDirectoryLabel(), ...
    "MenuSelectedFcn", @videoSelector.openDirectory, ...
    "Accelerator", "O" ...
    );
end

function generateRegionMenu(fig, trackingLinker)
m = uimenu(fig, "Text", "Region");
generateThresholdMenu(m, trackingLinker);
generateBlobDetectionMenu(m, trackingLinker);
generateResetMenu(m, trackingLinker);
end
function generateBlobDetectionMenu(parentMenu, trackingLinker)
uimenu(parentMenu, ...
    "Text", SettingsParser.getBlobDetectionFigureDefaults().Name, ...
    "MenuSelectedFcn", @trackingLinker.blobDetectionButtonPushed ...
    );
end
function generateResetMenu(parentMenu, trackingLinker)
resetKeywords = RegionUserData.keywords;
m = uimenu(parentMenu, "Text", SettingsParser.getResetRegionLabel());
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
uimenu(parentMenu, ...
    "Text", SettingsParser.getAutothresholdFigureDefaults().Name, ...
    "MenuSelectedFcn", @trackingLinker.regionThresholdButtonPushed ...
    );
end

function generatePlottingMenu(fig, trackingLinker)
m = uimenu(fig, "Text", "Plotting");
generateOpenWaterfallMenu(m, trackingLinker);
end
function generateOpenWaterfallMenu(parentMenu, trackingLinker)
uimenu(parentMenu, ...
    "Text", "Open Waterfall", ...
    "MenuSelectedFcn", @trackingLinker.openWaterfallPlotPushed ...
    );
end