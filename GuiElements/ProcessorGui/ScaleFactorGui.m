classdef ScaleFactorGui
    properties (Access = private)
        gridLayout;
        label;
        plusMinus;
        scaleFactorField;
        scaleFactorErrorField
    end

    methods
        function obj = ScaleFactorGui(parent)
            gl = uigridlayout( ...
                parent, [1, 4], ...
                "Padding", 0, ...
                "RowHeight", 25, ...
                "ColumnWidth", {75, '1x', 'fit', '1x'} ...
                );
            
            factorDefaults = SettingsParser.getScaleFactorDefaults();
            errorDefaults = SettingsParser.getScaleFactorErrorDefaults();
            obj.label = uilabel(gl, "Text", "length/px");
            obj.scaleFactorField = uieditfield(gl, "numeric", factorDefaults{:});
            obj.plusMinus = uilabel(gl, "Text", "±");
            obj.scaleFactorErrorField = uieditfield(gl, "numeric", errorDefaults{:});

            obj.gridLayout = gl;
        end
    end


    %% Functions to retrieve GUI elements
    methods
        function gl = getGridLayout(obj)
            gl = obj.gridLayout;
        end
        function elem = getField(obj)
            elem = obj.scaleFactorField;
        end
        function elem = getErrorField(obj)
            elem = obj.scaleFactorErrorField;
        end
    end

    %% Functions to retrieve state information
    methods
        function text = getLocation(obj)
            elem = obj.getField();
            text = get(elem, "Value");
        end
    end

    %% Functions to set state information
    methods
        function setLocation(obj, location)
            switch location
                case DirectionGui.tags(1, 3) % upper right
                    button = obj.buttons(1, 3);
                case DirectionGui.tags(1, 2) % upper
                    button = obj.buttons(1, 2);
                case DirectionGui.tags(1, 1)
                    button = obj.buttons(1, 1); % upper left
                case DirectionGui.tags(2, 1)
                    button = obj.buttons(2, 1); % left
                case DirectionGui.tags(3, 1)
                    button = obj.buttons(3, 1); % lower left
                case DirectionGui.tags(3, 2)
                    button = obj.buttons(3, 2); % lower
                case DirectionGui.tags(3, 3)
                    button = obj.buttons(3, 3); % lower right
                case DirectionGui.tags(2, 3)
                    button = obj.buttons(2, 3); % right
            end
            obj.setSelectedButton(button);
        end
    end
    methods (Access = private)
        function setSelectedButton(obj, button)
            group = obj.getRadioGroup();
            set(group, "SelectedObject", button);
        end
    end
end
