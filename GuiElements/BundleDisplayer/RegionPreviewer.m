classdef RegionPreviewer < RectangleDrawer
    properties (Access = private)
        %#ok<*PROPLC>
        fullGui;
        regionGui;
    end

    methods
        function obj = RegionPreviewer(fullGui, regionGui)
            ax = fullGui.getAxis();
            obj@RectangleDrawer(ax);
            obj.setUserDataFcn(@fullGui.getRegionUserData);
            
            iIm = fullGui.getInteractiveImage();
            set(iIm, "ButtonDownFcn", @obj.buttonDownFcn); % draw rectangles on image
            obj.fullGui = fullGui;
            obj.regionGui = regionGui;
        end
    end

    methods (Access = private)
        function buttonDownFcn(obj, source, event)
            if isLeftClick(event)
                rect = obj.generateRectangle(source, event);
                obj.previewGeneratedRegion(rect);
            end
        end
        function previewGeneratedRegion(obj, region)
            obj.addListeners(region);
            obj.setPreviewRegion(region);
        end

        function addListeners(obj, region)
            addlistener(region, "MovingROI", @obj.regionMoving);
            addlistener(region, "ROIClicked", @obj.regionClicked);
        end
        function regionMoving(obj, source, ~)
            obj.setPreviewRegion(source);
        end
        function regionClicked(obj, source, event)
            if isLeftClick(event)
                obj.setPreviewRegion(source);
            end
        end

        function setPreviewRegion(obj, region)
            regionRawImage = obj.getRegionalRawImage(region);
            obj.regionGui.setRegion(region, regionRawImage);
        end
        function regionRawImage = getRegionalRawImage(obj, region)
            im = obj.fullGui.getRawImage();
            regionRawImage = unpaddedMatrixInRegion(region, im);
        end
    end
end



function is = isLeftClick(event)
name = event.EventName;
if name == "ROIClicked"
    is = event.SelectionType == "left";
elseif name == "Hit"
    is = event.Button == 1;
end
end

function unpaddedMatrix = unpaddedMatrixInRegion(region, im)
regionMask = createMask(region, im);
im(regionMask == 0) = 0;
unpaddedMatrix = unpadMatrix(im);
end
function unpaddedMatrix = unpadMatrix(matrix)
[nonzeroRows, nonzeroColumns] = find(matrix);
nonzeroRowsSlice = min(nonzeroRows):max(nonzeroRows);
nonzeroColumnsSlice = min(nonzeroColumns):max(nonzeroColumns);
unpaddedMatrix = matrix(nonzeroRowsSlice, nonzeroColumnsSlice);
end
