function ax = generateEmptyAxis(gl)
ax = uiaxes(gl, ...
    "Toolbar", [], ...
    "Visible", "off", ...
    "XtickLabel", [], ...
    "YTickLabel", [] ...
    );
end
