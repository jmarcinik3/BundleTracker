function fig = generateFigure(varargin)
fig = uifigure(varargin{:});

darkRgb = SettingsParser.getColormapDarkColor();
mapName = SettingsParser.getColormapName();
brightRgb = SettingsParser.getColormapBrightColor();

cmap = colormap(fig, mapName); % set common pixel colormap
cmap(1, :) = darkRgb; % set dark pixel color
cmap(end, :) = brightRgb; % set saturated pixel color
colormap(fig, cmap);
end