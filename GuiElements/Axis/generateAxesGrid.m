function panel = generateAxesGrid(parent, axisCount)
panel = generatePanel(parent);
tl = tiledlayout(panel, "flow");
for axisIndex = 1:axisCount
    ax = generateEmptyAxis(tl);
    ax.Layout.Tile = axisIndex;
end
end

function panel = generatePanel(parent)
panel = uipanel(parent, ...
    "BorderType", "line", ...
    "BorderWidth", 0 ...
    );
end