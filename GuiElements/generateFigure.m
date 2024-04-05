function fig = generateFigure(varargin)
fig = uifigure(varargin{:});
cmap = colormap(fig, "turbo");
cmap(1, :) = 0; % set dark pixels as black
cmap(end, :) = 1; % set saturated pixels as white
colormap(fig, cmap);
end