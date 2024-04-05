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
