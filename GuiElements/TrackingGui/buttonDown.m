function buttonDown(~, ~, event)
source = event.Source;

if isRightClickedAxis(source)
    openAxisContextMenu(source);
end
end

function is = isRightClickedAxis(source)
clickedObj = source.CurrentObject;
is = ~isempty(clickedObj) ...
    && isequal(source.SelectionType, "alt") ...
    && isequal(clickedObj.Parent.Type, "axes");
end
function openAxisContextMenu(source)
ax = ancestor(source.CurrentObject.Parent, "axes");
cm = ax.ContextMenu;
if numel(cm) == 1
    mousePosition = source.CurrentPoint - [0, 25];
    cm.open(mousePosition(1), mousePosition(2));
end
end