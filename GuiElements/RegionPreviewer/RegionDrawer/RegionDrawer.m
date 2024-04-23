classdef RegionDrawer < RegionShaper
    properties (Access = private)
        userDataFcn;
    end

    methods
        function obj = RegionDrawer(ax, userDataFcn)
            obj@RegionShaper(ax);
            obj.userDataFcn = userDataFcn;
        end
    end

    %% Functions to generate GUI elements
    methods (Access = protected)
        function region = drawRegionOnClick(obj, ~, event)
            point = event.IntersectionPoint(1:2);
            region = obj.byPoint(point);
            configureRegion(obj, region);
        end

        function region = importRegion(obj, regionInfo)
            regionInfo = getRegionMetadata(regionInfo);
            ax = obj.getAxis();
            varargin = namedargs2cell(rmfield(regionInfo, "Type"));
            region = importRegion(ax, regionInfo.Type, varargin{:});
            configureRegion(obj, region);
        end
        function region = drawRegionByParameters(obj, parameters, keyword)
            ax = obj.getAxis();
            region = drawRegionByParameters(ax, parameters, keyword);
            configureRegion(obj, region);
        end
    end
    methods (Access = private)
        function region = byPoint(obj, point)
            region = obj.generateRegionByKeyword();
            beginDrawingFromPoint(region, point);
            configureRegion(obj, region);
        end
    end

    %% Functions to retrieve GUI elements and state information
    methods (Static)
        function regions = getRegions(obj)
            if isa(obj, "matlab.ui.control.UIAxes")
                regions = findobj(obj.Children, "Type", "images.roi");
                regions = flip(regions);
            elseif isa(obj, "images.roi.Rectangle") ...
                    || isa(obj, "images.roi.Ellipse") ...
                    || isa(obj, "images.roi.Polygon") ...
                    || isa(obj, "images.roi.Freehand")
                ax = ancestor(obj, "axes");
                regions = RegionDrawer.getRegions(ax);
            end
        end
    end
end



function configureRegion(obj, region)
defaults = SettingsParser.getRegionDefaults();
set(region, ...
    defaults{:}, ...
    "UserData", obj.userDataFcn() ...
    );
RegionUpdater.update(region);
end

function region = importRegion(ax, regionType, varargin)
switch regionType
    case 'images.roi.rectangle'
        region = images.roi.Rectangle(ax, varargin{:});
    case 'images.roi.ellipse'
        region = images.roi.Ellipse(ax, varargin{:});
    case 'images.roi.polygon'
        region = images.roi.Polygon(ax, varargin{:});
    case 'images.roi.freehand'
        region = images.roi.Freehand(ax, varargin{:});
end
end
