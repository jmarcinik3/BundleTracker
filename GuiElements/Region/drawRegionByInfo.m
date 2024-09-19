function region = drawRegionByInfo(ax, regionInfo)
regionInfo = getRegionMetadata(regionInfo);
regionType = regionInfo.Type;
varargin = namedargs2cell(rmfield(regionInfo, "Type"));
if strcmpi(regionType, "images.roi.rectangle")
    region = images.roi.Rectangle(ax, varargin{:});
elseif strcmpi(regionType, "images.roi.ellipse")
    region = images.roi.Ellipse(ax, varargin{:});
elseif strcmpi(regionType, "images.roi.polygon")
    region = images.roi.Polygon(ax, varargin{:});
elseif strcmpi(regionType, "images.roi.freehand")
    region = images.roi.Freehand(ax, varargin{:});
end
end