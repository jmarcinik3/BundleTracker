function resizeAxis(ax, h, w)
if w > 0 && h > 0
    if axisIsRoughlySquare(h, w)
        resizeAxisRoughlySquare(ax, h, w);
    elseif imageIsWide(h, w)
        resizeAxisWide(ax, h, w);
    elseif axisIsTall(h, w)
        resizeAxisTall(ax, h, w);
    end
end
end

function is = axisIsRoughlySquare(h, w)
is = w <= 2 * h && h <= 2 * w;
end
function is = imageIsWide(h, w)
is = w > 2 * h;
end
function is = axisIsTall(h, w)
is = h > 2 * w;
end

function resizeAxisRoughlySquare(ax, h, w)
set(ax, ...
    "XLim", [0, w], ...
    "YLim", [0, h] ...
    );
pbaspect(ax, [w, h, 1]);
end
function resizeAxisWide(ax, ~, w)
set(ax, ...
    "XLim", [0, w], ...
    "YLim", w * [-0.5, 0.5] ...
    );
pbaspect(ax, [1 1 1]);
end
function resizeAxisTall(ax, h, ~)
set(ax, ...
    "XLim", h * [-0.5, 0.5], ...
    "YLim", [0, h] ...
    );
pbaspect(ax, [1 1 1]);
end
