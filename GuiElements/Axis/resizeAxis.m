function resizeAxis(ax, h, w, varargin)
p = inputParser;
addOptional(p, "FitToContent", false);
parse(p, varargin{:});
fitToContent = p.Results.FitToContent;

if w > 0 && h > 0
    if h == w || fitToContent
        resizeAxisToContent(ax, h, w);
    elseif w > h
        resizeAxisWide(ax, h, w);
    elseif w < h
        resizeAxisTall(ax, h, w);
    end
end
end



function resizeAxisToContent(ax, h, w)
xlim = w * [0, 1];
ylim = h * [0, 1];
set(ax, "XLim", xlim, "YLim", ylim);
pbaspect(ax, [w, h, 1]);
end
function resizeAxisWide(ax, h, w)
xlim = w * [0, 1];
ylim = h / 2 + w * [-0.5, 0.5];
set(ax, "XLim", xlim, "YLim", ylim);
pbaspect(ax, [1, 1, 1]);
end
function resizeAxisTall(ax, h, w)
xlim = w / 2 + h * [-0.5, 0.5];
ylim = h * [0, 1];
set(ax, "XLim", xlim, "YLim", ylim);
pbaspect(ax, [1, 1, 1]);
end
