classdef AxisAnimator < handle
    methods (Abstract)
        clearAnimation(obj);
        updateAnimation(obj, frameIndex);
    end

    methods (Access = protected)
        function frame = getCurrentFrame(obj)
            fig = obj.getFigure();
            frame = getframe(fig).cdata;
        end
    end

    properties (Constant, Access = private)
        extensions = { ...
            '*.gif', "Graphic Interchange Format"; ...
            '*.avi', "Audio Video Interleave"; ...
            '*.mj2', "Motion JPEG 2000"; ...
            '*.mp4', "MPEG-4 file"; ...
            };
    end

    properties (Access = private)
        axis;
        contextMenu;
        time;
        playbackFps = 30; % FPS
        playbackSpeed = 1 / 5; % playback time / real time
        isLooping = false;
    end

    methods
        function obj = AxisAnimator(ax, t, varargin)
            p = inputParser();
            p.addOptional("PlaybackFps", 30);
            p.addOptional("PlaybackSpeed", 1);
            p.parse(varargin{:});

            fig = ancestor(ax, "figure");
            contextMenu = uicontextmenu(fig);
            uimenu(contextMenu, ...
                "Label", "Start Animation", ...
                "Callback", @(src,ev) obj.startAnimation() ...
                );
            uimenu(contextMenu, ...
                "Label", "Stop Animation", ...
                "Callback", @(src,ev) obj.stopAnimation() ...
                );
            uimenu(contextMenu, ...
                "Separator", true, ...
                "Label", "Set Playback FPS", ...
                "Callback", @obj.uiSetPlaybackFps ...
                );
            uimenu(contextMenu, ...
                "Label", "Set Playback Speed", ...
                "Callback", @obj.uiSetPlaybackSpeed ...
                );
            uimenu(contextMenu, ...
                "Label", "Toggle Axis Visibility", ...
                "Callback", @obj.toggleAxisVisibility ...
                );
            uimenu(contextMenu, ...
                "Separator", true, ...
                "Label", "Export Animation", ...
                "Callback", @(src,ev) obj.exportAnimation() ...
                );
            set([fig, ax], "ContextMenu", contextMenu);

            obj.playbackFps = p.Results.PlaybackFps;
            obj.playbackSpeed = p.Results.PlaybackSpeed;

            obj.time = t;
            obj.axis = ax;
            obj.contextMenu = contextMenu;
        end
    end

    %% Functions to retrieve GUI elements
    methods
        function fig = getFigure(obj)
            ax = obj.getAxis();
            fig = ancestor(ax, "figure");
        end
        function ax = getAxis(obj)
            ax = obj.axis;
        end
        function menu = getContextMenu(obj)
            menu = obj.contextMenu;
        end
        function t = getTime(obj, frameIndex)
            t = obj.time;
            if nargin == 2
                inds = obj.getFrameSlice(frameIndex);
                t = t(inds);
            end
        end
        function fps = getPlaybackFps(obj)
            fps = obj.playbackFps;
        end
        function dilation = getPlaybackSpeed(obj)
            dilation = obj.playbackSpeed;
        end
    end

    %% Functions to calculate state information
    methods
        function length = getDuration(obj)
            t = obj.getTime();
            length = t(end) - t(1);
        end
        function frameCount = getFrameCount(obj)
            playbackFps = obj.getPlaybackFps();
            playbackSpeed = obj.getPlaybackSpeed();
            timeLength = obj.getDuration();
            frameCount = ceil(playbackFps * timeLength / playbackSpeed);
        end
        function inds = getFrameSlice(obj, index)
            timeCount = numel(obj.getTime());
            frameCount = obj.getFrameCount();
            locations = round(linspace(1, timeCount, frameCount+1));
            inds = locations(index):locations(index+1);
        end
        function s = getVideoSize(obj)
            frameCount = obj.getFrameCount();
            nullFrame = obj.getCurrentFrame();
            [height, width, colorChannels] = size(nullFrame);
            s = [height, width, colorChannels, frameCount];
        end
    end

    %% Functions to set state through GUI
    methods
        function uiSetPlaybackFps(obj, ~, ~)
            default = {num2str(obj.getPlaybackFps())};
            answer = inputdlg( ...
                "Enter rate (int)", ...
                "Playback FPS", ...
                1, ...
                default ...
                );
            if isempty(answer)
                return;
            end
            playbackFps = str2double(answer{1});
            obj.setPlaybackFps(playbackFps);
        end
        function uiSetPlaybackSpeed(obj, ~, ~)
            default = {num2str(obj.getPlaybackSpeed())};
            answer = inputdlg( ...
                "Enter speed (float)", ...
                "Playback Speed", ...
                1, ...
                default ...
                );
            if isempty(answer)
                return;
            end
            playbackSpeed = str2double(answer{1});
            obj.setPlaybackSpeed(playbackSpeed);
        end
    end

    %% Functions to set state of GUI elements
    methods
        function setPlaybackFps(obj, fps)
            obj.playbackFps = fps;
            if obj.isLooping
                obj.startAnimation();
            end
        end
        function setPlaybackSpeed(obj, speed)
            obj.playbackSpeed = speed;
            if obj.isLooping
                obj.startAnimation();
            end
        end

        function toggleAxisVisibility(obj, ~, ~)
            ax = obj.getAxis();
            visiblePre = get(ax, "Visible");
            if strcmpi(visiblePre, "on")
                visiblePost = "off";
            else
                visiblePost = "on";
            end
            set(ax, "Visible", visiblePost);
        end
    end

    %% Functions to run and export animation
    methods
        function frames = getFrames(obj)
            frameCount = obj.getFrameCount();
            frameSize = obj.getVideoSize();
            frames = zeros(frameSize, "uint8");

            obj.clearAnimation();
            for frameIndex = 1:frameCount
                obj.updateAnimation(frameIndex);
                frame = im2uint8(obj.getCurrentFrame());
                frames(:, :, :, frameIndex) = frame;
            end
        end

        function startAnimation(obj)
            obj.isLooping = true;
            ax = obj.getAxis();
            delayTime = 1 / obj.getPlaybackFps();
            frameCount = obj.getFrameCount();

            obj.clearAnimation();
            pause(delayTime);

            while ishandle(ax) && obj.isLooping
                for frameIndex = 1:frameCount
                    pause(delayTime);
                    if ~ishandle(ax) || ~obj.isLooping
                        return;
                    end
                    obj.updateAnimation(frameIndex);
                end

                obj.clearAnimation();
                pause(delayTime);
                if ~ishandle(ax) || ~obj.isLooping
                    return;
                end
            end
        end
        function stopAnimation(obj)
            obj.isLooping = false;
        end

        function exportAnimation(obj)
            [filepath, isfilepath] = uiputfilepath( ...
                obj.extensions, ...
                "Export Animation" ...
                );
            if ~isfilepath
                return;
            end

            startedLooping = obj.isLooping;
            obj.stopAnimation();
            obj.clearAnimation();

            if endsWith(filepath, ".gif")
                obj.exportGif(filepath);
            elseif endsWith(filepath, [".avi", ".mp4", ".mv4"])
                obj.exportVideo(filepath);
            elseif endsWith(filepath, ".mj2")
                obj.exportMj2(filepath)
            end

            if startedLooping
                obj.startAnimation();
            end
        end
        function exportGif(obj, filepath)
            taskName = 'Exporting GIF Animation';
            multiWaitbar(taskName, 0, 'CanCancel', 'on');

            frames = obj.getFrames();
            frameCount = obj.getFrameCount();
            delayTime = 1 / obj.getPlaybackFps();

            [frame, cmap] = rgb2ind(frames(:, :, :, 1), 256);
            imwrite( ...
                frame, ...
                cmap, ...
                filepath, ...
                "gif", ...
                "WriteMode", "Overwrite", ...
                "DelayTime", delayTime, ...
                "LoopCount", Inf ...
                );

            cancel = false;
            proportionDelta = 1 / frameCount;
            for frameIndex = 2:frameCount
                frameRgb = frames(:, :, :, frameIndex);
                [frame, cmap] = rgb2ind(frameRgb, 256);
                imwrite( ...
                    frame, ...
                    cmap, ...
                    filepath, ...
                    "gif", ...
                    "WriteMode", "Append", ...
                    "DelayTime", delayTime ....
                    );

                proportionComplete = frameIndex / frameCount;
                if mod(proportionComplete, 0.01) < proportionDelta
                    cancel = multiWaitbar(taskName, proportionComplete);
                end
                if cancel
                    break;
                end
            end

            multiWaitbar(taskName, 'Close');
        end
        function exportMj2(obj, filepath)
            taskName = 'Exporting Video';
            multiWaitbar(taskName, 0, 'CanCancel', 'on');
            
            playbackFps = obj.getPlaybackFps();
            frames = im2uint16(obj.getFrames());
            frameCount = obj.getFrameCount();

            videoProfile = videoProfileFromExtension(filepath);
            videoWriter = VideoWriter(filepath, videoProfile);
            set(videoWriter, "FrameRate", playbackFps);
            
            videoWriter.open();
            cancel = false;
            proportionDelta = 1 / frameCount;
            for frameIndex = 1:frameCount
                frame = frames(:, :, frameIndex);
                videoWriter.writeVideo(frame);
                proportionComplete = frameIndex / frameCount;
                if mod(proportionComplete, 0.01) < proportionDelta
                    cancel = multiWaitbar(taskName, proportionComplete);
                end
                if cancel
                    break;
                end
            end
            
            close(videoWriter);
            multiWaitbar(taskName, 'Close');
        end
        function exportVideo(obj, filepath)
            taskName = 'Exporting Video';
            multiWaitbar(taskName, 0, 'CanCancel', 'on');

            playbackFps = obj.getPlaybackFps();
            frames = obj.getFrames();
            frameCount = obj.getFrameCount();

            videoProfile = videoProfileFromExtension(filepath);
            videoWriter = VideoWriter(filepath, videoProfile);
            set(videoWriter, "FrameRate", playbackFps);

            if strcmp(videoProfile, "Archival")
                frames = reshape(im2uint16(frames), []);
            end

            videoWriter.open();
            cancel = false;
            proportionDelta = 1 / frameCount;
            for frameIndex = 1:frameCount
                frame = frames(:, :, :, frameIndex);
                videoWriter.writeVideo(frame);
                proportionComplete = frameIndex / frameCount;
                if mod(proportionComplete, 0.01) < proportionDelta
                    cancel = multiWaitbar(taskName, proportionComplete);
                end
                if cancel
                    break;
                end
            end

            videoWriter.close()
            multiWaitbar(taskName, 'Close');
        end
    end
end


function profile = videoProfileFromExtension(extension)
if endsWith(extension, ".avi")
    profile = "Motion JPEG AVI";
elseif endsWith(extension, [".mp4", ".mv4"])
    profile = "MPEG-4";
elseif endsWith(extension, ".mj2")
    profile = "Archival";
end
end
