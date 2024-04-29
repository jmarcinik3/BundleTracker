classdef RegionDrawer < handle
    properties (Constant)
        rectangleKeyword = "Rectangle";
        ellipseKeyword = "Ellipse";
        polygonKeyword = "Polygon";
        freehandKeyword = "Freehand";
    end

    properties (Access = private)
        shapeKeyword = RegionDrawer.rectangleKeyword;
    end

    methods (Abstract, Access = protected)
        getRegionUserData(obj);
        getAxis(obj);
    end

    %% Functions to generate GUI elements
    methods (Access = protected)
        function region = drawRegionOnClick(obj, ~, event)
            ax = obj.getAxis();
            keyword = obj.getRegionShape();
            point = event.IntersectionPoint(1:2);

            region = drawRegionByKeyword(ax, keyword);
            configureRegion(obj, region);
            beginDrawingFromPoint(region, point);
        end

        function region = importRegion(obj, regionInfo)
            ax = obj.getAxis();
            region = drawRegionByInfo(ax, regionInfo);
            configureRegion(obj, region);
        end
        function region = drawRegionByParameters(obj, parameters, keyword)
            ax = obj.getAxis();
            region = drawRegionByParameters(ax, parameters, keyword);
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
    methods
        function shape = getRegionShape(obj)
            shape = obj.shapeKeyword;
        end
    end

    %% Functions to set state information
    methods
        function setRegionShape(obj, shapeKeyword)
            obj.shapeKeyword = shapeKeyword;
        end
        function setRectangleShape(obj, ~, ~)
            obj.setRegionShape(RegionDrawer.rectangleKeyword);
        end
        function setEllipseShape(obj, ~, ~)
            obj.setRegionShape(RegionDrawer.ellipseKeyword);
        end
        function setPolygonShape(obj, ~, ~)
            obj.setRegionShape(RegionDrawer.polygonKeyword);
        end
        function setFreehandShape(obj, ~, ~)
            obj.setRegionShape(RegionDrawer.freehandKeyword);
        end
    end
end



function configureRegion(obj, region)
defaults = SettingsParser.getRegionDefaults();
set(region, ...
    defaults{:}, ...
    "UserData", obj.getRegionUserData() ...
    );
RegionUpdater.update(region);
end

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

function region = drawRegionByParameters(ax, parameters, keyword)
switch keyword
    case BlobDrawer.ellipseKeyword
        region = images.roi.Ellipse(ax, ...
            "Center", parameters(1:2), ...
            "RotationAngle", rad2deg(parameters(5)), ...
            "SemiAxes", parameters(3:4) ...
            );
    case BlobDrawer.rectangleKeyword
        region = images.roi.Rectangle(ax, "Position", parameters);
end
end

function region = drawRegionByKeyword(ax, keyword)
switch keyword
    case RegionDrawer.rectangleKeyword
        region = images.roi.Rectangle(ax);
    case RegionDrawer.ellipseKeyword
        region = images.roi.Ellipse(ax);
    case RegionDrawer.polygonKeyword
        region = images.roi.Polygon(ax);
    case RegionDrawer.freehandKeyword
        region = images.roi.Freehand(ax);
end
end
