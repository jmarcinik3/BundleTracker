classdef AxisResizer
    properties (Access = private)
        interactiveImage;
        fitToContent;
    end

    methods
        function obj = AxisResizer(interactiveImage, varargin)
            p = inputParser;
            addOptional(p, "FitToContent", true);
            addOptional(p, "AddListener", true);
            parse(p, varargin{:});
            obj.fitToContent = p.Results.FitToContent;
            addListener = p.Results.AddListener;

            obj.interactiveImage = interactiveImage;
            if addListener
                addlistener(interactiveImage, "CData", "PostSet", @obj.resizeAxis);
            end
            obj.resizeAxis();
        end
    end

    %% Functions to retrieve GUI elements and state information
    methods (Access = private)
        function ax = getAxis(obj)
            iIm = obj.getInteractiveImage();
            ax = ancestor(iIm, "axes");
        end
        function iIm = getInteractiveImage(obj)
            iIm = obj.interactiveImage;
        end
        function [h, w] = getImageSize(obj)
            iIm = obj.getInteractiveImage();
            im = get(iIm, "CData");
            [h, w, ~] = size(im);
        end
    end

    %% Functions to update state of GUI
    methods (Access = private)
        function resizeAxis(obj, ~, ~)
            fitToContent = obj.fitToContent;
            ax = obj.getAxis();
            [h, w] = obj.getImageSize();
            resizeAxis(ax, h, w, "FitToContent", fitToContent);
        end
    end
end