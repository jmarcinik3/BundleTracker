function buttons = generateActionButtons(gl)
applyButton = uibutton(gl, "Text", "Apply");
cancelButton = uibutton(gl, "Text", "Cancel");
buttons = [applyButton, cancelButton];
end