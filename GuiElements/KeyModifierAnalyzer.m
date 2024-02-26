classdef KeyModifierAnalyzer
    properties
        hasShift;
        hasCtrl;
        hasAlt;

        hasPureCtrl;
        hasPureAlt;
        hasPureCtrlShift;
        hasCtrlShiftAlt;

        hasZeroModifiers;
        hasOneModifier;
        hasTwoModifiers;
    end
    
    methods
        function obj = KeyModifierAnalyzer(modifiers)
            modifierCount = numel(modifiers);
            hasZeroModifiers = modifierCount == 0;
            hasOneModifier = modifierCount == 1;
            hasTwoModifiers = modifierCount == 2;

            hasShift = any(ismember(modifiers, "shift"));
            hasCtrl = any(ismember(modifiers, "control"));
            hasAlt = any(ismember(modifiers, "alt"));

            obj.hasPureCtrl = hasCtrl && hasOneModifier;
            obj.hasPureAlt = hasAlt && hasOneModifier;
            obj.hasPureCtrlShift = hasCtrl && hasShift && hasTwoModifiers;
            obj.hasCtrlShiftAlt = hasCtrl && hasShift && hasAlt;

            obj.hasShift = hasShift;
            obj.hasCtrl = hasCtrl;
            obj.hasAlt = hasAlt;

            obj.hasZeroModifiers = hasZeroModifiers;
            obj.hasOneModifier = hasOneModifier;
            obj.hasTwoModifiers = hasTwoModifiers;
        end
    end
end

