classdef AxisVideoAnimator < AxisAnimator
    properties (Access = private)
        frames;
        interactiveImage;
    end

    methods
        function obj = AxisVideoAnimator(ax, t, ims, varargin)
            obj@AxisAnimator(ax, t, varargin{:});

            firstFrame = ims(:, :, :, 1);
            interactiveImage = imshow(firstFrame, "Parent", ax);
            set(interactiveImage, "ContextMenu", obj.getContextMenu());
            AxisResizer(interactiveImage);

            obj.frames = ims;
            obj.interactiveImage = interactiveImage;
        end
    end

    %% Functions to instantiate abstract methods
    methods
        function frames = getFrame(obj, frameIndex)
            frames = obj.frames;
            if nargin == 2
                inds = obj.getFrameSlice(frameIndex);
                ind = round(median(inds));
                frames = frames(:, :, :, ind);
            end
        end
        function clearAnimation(obj)
            iIm = obj.getInteractiveImage();
            firstFrame = obj.getFrame(1);
            set(iIm, "CData", firstFrame);
        end
        function updateAnimation(obj, frameIndex)
            iIm = obj.getInteractiveImage();
            im = obj.getFrame(frameIndex);
            set(iIm, "CData", im);
        end
    end

    %% Functions to overwrite default methods
    methods (Access = protected)
        function frame = getCurrentFrame(obj)
            iIm = obj.getInteractiveImage();
            frame = get(iIm, "CData");
        end
    end

    %% Functions to retrieve GUI elements
    methods
        function iIm = getInteractiveImage(obj)
            iIm = obj.interactiveImage;
        end
    end
end
