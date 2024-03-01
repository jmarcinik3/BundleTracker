function startTrackingGui(varargin)
gui = TrackingGui();
linker = TrackingLinker(gui, varargin{:});
end