classdef PostprocessorGui
    properties (Access = private)
        gridLayout;
        directionGui;
        trackingSelection;
        angleSelection;
    end

    methods
        function obj = PostprocessorGui(gl)
            obj.directionGui = DirectionGui(gl);
            obj.trackingSelection = generateTrackingSelection(gl);
            obj.angleSelection = generateAngleSelection(gl);
            obj.gridLayout = gl;
        end
    end

    %% Functions to retrieve GUI elements
    methods
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
    end

    %% Functions to retrieve state information
    methods
        function data = getRegionUserData(obj)
            trackingMode = obj.getTrackingMode();
            angleMode = obj.getAngleMode();
            direction = obj.getPositiveDirection();
            data = struct( ...
                RegionParser.trackingKeyword, trackingMode, ...
                RegionParser.angleKeyword, angleMode, ...
                RegionParser.directionKeyword, direction ...
                );
        end
    end
    methods (Access = private)
        function trackingMode = getTrackingMode(obj)
            trackingMode = obj.trackingSelection.Value;
        end
        function angleMode = getAngleMode(obj)
            angleMode = obj.angleSelection.Value;
        end
        function direction = getPositiveDirection(obj)
            direction = obj.directionGui.getLocation();
        end
    end
end


%% Function to generate tracking method dropdown
% Generates dropdown menu allowing user to select tracking method (e.g.
% "Centroid")
%
% Arguments
%
% * uigridlayout |gl|: layout to add dropdown in
%
% Returns uiddropdown
function dropdown = generateTrackingSelection(gl)
dropdown = uidropdown(gl);
dropdown.Items = TrackingAlgorithms.keywords;
end

%% Function to generate angle method dropdown
% Generates dropdown menu allowing user to select tracking method (e.g.
% "Centroid")
%
% Arguments
%
% * uigridlayout |gl|: layout to add dropdown in
%
% Returns uiddropdown
function dropdown = generateAngleSelection(gl)
dropdown = uidropdown(gl);
dropdown.Items = AngleAlgorithms.keywords;
end
