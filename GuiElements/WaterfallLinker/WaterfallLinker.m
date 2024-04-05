classdef WaterfallLinker < WaterfallAxes
    properties (Access = private)
        gui;
    end

    methods
        function obj = WaterfallLinker(gui, y, t)
            ax = gui.getAxis();
            obj@WaterfallAxes(ax, y, t);

            alphaSlider = gui.getAlphaSlider();
            % colorPicker = gui.getColorPicker();
            set(alphaSlider, "ValueChangingFcn", @obj.alphaChanging);
            % set(colorPicker, "ValueChangedFcn", @obj.colorChanged);

            alphaSlider.ValueChangingFcn(alphaSlider, struct("Value", alphaSlider.Value));
            % colorPicker.ValueChangedFcn(colorPicker, struct("Value", colorPicker.Value));

            obj.gui = gui;
        end
    end

    %% Functions to generate GUI
    methods (Static)
        function openFigure(traces, time)
            fig = uifigure();
            gui = WaterfallGui(fig);
            WaterfallLinker(gui, traces, time);
        end
    end

    %% Functions to update state of GUI
    methods (Access = protected)
        function afterAxisHover(obj, source, ~)
            labelElement = obj.gui.getLabelElement();
            set(labelElement, "Text", source.Tag);
        end
        function afterAxisExit(obj, ~, ~)
            labelElement = obj.gui.getLabelElement();
            set(labelElement, "Text", WaterfallGui.defaultLabel);
        end
    end
    methods (Access = private)
        function colorChanged(obj, ~, event)
            color = event.Value;
            obj.setColor(color);
            obj.updateAccentLines();
        end
        function alphaChanging(obj, ~, event)
            alpha = event.Value;
            obj.setDefaultAlpha(alpha);
            obj.updateAccentLines();
        end
    end
end