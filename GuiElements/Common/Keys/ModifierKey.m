classdef ModifierKey
    properties
        hasShift;
        hasCtrl;
        hasAlt;

        isPureCtrl;
        isPureAlt;
        isPureCtrlShift;
        isCtrlShiftAlt;

        hasZeroModifiers
    end

    methods
        function obj = ModifierKey(modifiers)
            if isa(modifiers, "matlab.ui.eventdata.KeyData")
                modifiers = modifiers.Modifier;
            end

            modifierCount = numel(modifiers);
            obj.hasZeroModifiers = modifierCount == 0;
            hasOneModifier = modifierCount == 1;
            hasTwoModifiers = modifierCount == 2;

            hasShift = modifierHasShift(modifiers);
            hasCtrl = modifierHasCtrl(modifiers);
            hasAlt = modifierHasAlt(modifiers);

            obj.isPureCtrl = hasCtrl && hasOneModifier;
            obj.isPureAlt = hasAlt && hasOneModifier;
            obj.isPureCtrlShift = hasCtrl && hasShift && hasTwoModifiers;
            obj.isCtrlShiftAlt = hasCtrl && hasShift && hasAlt;

            obj.hasShift = hasShift;
            obj.hasCtrl = hasCtrl;
            obj.hasAlt = hasAlt;
        end
    end
end



function has = modifierHasShift(modifiers)
has = any(ismember(modifiers, "shift"));
end
function has = modifierHasCtrl(modifiers)
has = any(ismember(modifiers, "control"));
end
function has = modifierHasAlt(modifiers)
has = any(ismember(modifiers, "alt"));
end
