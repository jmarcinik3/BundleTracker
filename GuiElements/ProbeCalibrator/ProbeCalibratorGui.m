classdef ProbeCalibratorGui
    properties (Constant)
        title = "Probe Calibrator";
    end

    properties (Access = private)
        gridLayout;
        axPsd;
        axRoi;
        resonanceCountSpinner;
        stiffnessLabel;
        dragLabel;
    end

    methods
        function obj = ProbeCalibratorGui(fig)
            set(fig, "Name", ProbeCalibratorGui.title);
            gl = uigridlayout(fig, [4, 2]);

            obj.axPsd = uiaxes(gl);
            obj.axRoi = uiaxes(gl);
            obj.resonanceCountSpinner = uispinner(gl, ...
                "Value", 0, ...
                "Limits", [0, 8] ...
                );

            obj.stiffnessLabel = uilabel(gl, ...
                "Text", "Stiffness:", ...
                "Interpreter", "latex" ...
                );
            obj.dragLabel = uilabel(gl, ...
                "Text", "Drag Coefficient:", ...
                "Interpreter", "latex" ...
                );

            obj.gridLayout = gl;
            layoutElements(obj);
        end
    end

    %% Functions to retrieve GUI elements
    methods
        function gl = getGridLayout(obj)
            gl = obj.gridLayout;
        end
        function axPsd = getAxisPsd(obj)
            axPsd = obj.axPsd;
        end
        function axRoi = getAxisRoi(obj)
            axRoi = obj.axRoi;
        end
        function label = getStiffnessLabel(obj)
            label = obj.stiffnessLabel;
        end
        function label = getDragLabel(obj)
            label = obj.dragLabel;
        end
        function spinner = getResonanceElement(obj)
            spinner = obj.resonanceCountSpinner;
        end
    end
end



function layoutElements(gui)
% retrieve GUI elements
gl = gui.getGridLayout();
axPsd = gui.getAxisPsd();
axRoi = gui.getAxisRoi();
peakCountSpinner = gui.getResonanceElement();
stiffnessLabel = gui.getStiffnessLabel();
dragLabel = gui.getDragLabel();

% generate labels for appropriate elements
resonanceCountLabel = uilabel(gl, "Text", "Resonance Count:");

% lay out axis elements
axPsd.Layout.Row = 1;
axPsd.Layout.Column = 1;
axRoi.Layout.Row = 1;
axRoi.Layout.Column = 2;

resonanceCountLabel.Layout.Row = 2;
resonanceCountLabel.Layout.Column = 1;

% lay out preprocessing elements
peakCountSpinner.Layout.Row = 2;
peakCountSpinner.Layout.Column = 2;

% lay out parameter-display elements
stiffnessLabel.Layout.Row = 3;
stiffnessLabel.Layout.Column = 1;
dragLabel.Layout.Row = 4;
dragLabel.Layout.Column = 1;

set(gl, ...
    "ColumnWidth", {'2x', '1x'}, ...
    "RowHeight", {'fit', 25, 25} ...
    );
end