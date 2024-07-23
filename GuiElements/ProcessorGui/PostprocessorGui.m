classdef PostprocessorGui
    properties (Access = private)
        gridLayout;
        directionGui;
        trackingSelection;
        angleSelection;
        detrendSelection;
    end

    methods
        function obj = PostprocessorGui(gl)
            obj.directionGui = DirectionGui(gl);
            obj.trackingSelection = generateTrackingSelection(gl);
            obj.angleSelection = generateAngleSelection(gl);
            obj.detrendSelection = generateDetrendSelection(gl);
            obj.gridLayout = gl;
        end
    end

    %% Functions to retrieve GUI elements
    methods
        function gl = getGridLayout(obj)
            gl = obj.gridLayout;
        end
        function gui = getDirectionGui(obj)
            gui = obj.directionGui;
        end
        function elem = getTrackingSelectionElement(obj)
            elem = obj.trackingSelection;
        end
        function elem = getAngleSelectionElement(obj)
            elem = obj.angleSelection;
        end
        function elem = getPositiveDirectionElement(obj)
            elem = obj.directionGui.getGridLayout();
        end
        function elem = getDetrendSelectionElement(obj)
            elem = obj.detrendSelection;
        end
    end

    %% Functions to retrieve state information
    methods
        function regionUserData = getRegionUserData(obj)
            trackingMode = obj.getTrackingMode();
            angleMode = obj.getAngleMode();
            detrendMode = obj.getDetrendMode();
            direction = obj.getPositiveDirection();
            
            regionUserData = RegionUserData();
            regionUserData.setTrackingMode(trackingMode);
            regionUserData.setAngleMode(angleMode);
            regionUserData.setDetrendMode(detrendMode);
            regionUserData.setPositiveDirection(direction);
        end
    end
    methods (Access = private)
        function trackingMode = getTrackingMode(obj)
            trackingMode = obj.trackingSelection.Value;
        end
        function angleMode = getAngleMode(obj)
            angleMode = obj.angleSelection.Value;
        end
        function detrend = getDetrendMode(obj)
            detrend = obj.detrendSelection.Value;
        end
        function direction = getPositiveDirection(obj)
            direction = obj.directionGui.getLocation();
        end
    end
end


%% Function to generate tracking method dropdown
% Generates dropdown menu allowing user to select tracking method
%
% Arguments
%
% * uigridlayout |gl|: layout to add dropdown in
%
% Returns uiddropdown
function dropdown = generateTrackingSelection(gl)
defaults = SettingsParser.getTrackingModeDefaults();
dropdown = uidropdown(gl, ...
    "Items", TrackingAlgorithms.keywords, ...
    defaults{:} ...
    );
end

%% Function to generate angle method dropdown
% Generates dropdown menu allowing user to select angle method
%
% Arguments
%
% * uigridlayout |gl|: layout to add dropdown in
%
% Returns uiddropdown
function dropdown = generateAngleSelection(gl)
defaults = SettingsParser.getAngleModeDefaults();
dropdown = uidropdown(gl, ...
    "Items", AngleAlgorithms.keywords, ...
    defaults{:} ...
    );
end

%% Function to generate detrend method dropdown
% Generates dropdown menu allowing user to select detrend method
%
% Arguments
%
% * uigridlayout |gl|: layout to add dropdown in
%
% Returns uiddropdown
function dropdown = generateDetrendSelection(gl)
defaults = SettingsParser.getDetrendModeDefaults();
dropdown = uidropdown(gl, ...
    "Items", DetrendAlgorithms.keywords, ...
    defaults{:} ...
    );
end
