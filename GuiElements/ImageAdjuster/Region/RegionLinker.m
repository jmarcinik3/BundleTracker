classdef RegionLinker < PreprocessorLinker
    properties (Access = private)
        fullRawImage;
        regionGui;
    end

    methods
        function obj = RegionLinker(regionGui, fullRawImage)
            % regionMoverGui = regionGui.getRegionMoverGui();
            % regionCompressorGui = regionGui.getRegionCompressorGui();
            % regionExpanderGui = regionGui.getRegionExpanderGui();
            obj@PreprocessorLinker(regionGui);

            iIm = regionGui.getInteractiveImage();
            AxisResizer(iIm, "FitToContent", true);
            obj.fullRawImage = fullRawImage;
            obj.regionGui = regionGui;
        end
    end

    %% Functions to retreive GUI elements
    methods
        function gui = getRegionGui(obj)
            gui = obj.regionGui;
        end
    end

    %% Functions to update GUI and state information
    methods
        function changeImage(obj, im)
            obj.fullRawImage = im;
        end
    end
    methods (Access = ?RegionPreviewer)
        function updateRegionalRawImage(obj, region)
            if RegionType.isRegion(region)
                fullRawImage = obj.fullRawImage;
                regionRawImage = MatrixUnpadder.byRegion2d(region, fullRawImage);
            else
                regionRawImage = [];
            end
            obj.setRawImage(regionRawImage);
        end
    end
end
