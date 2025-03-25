function angle = directionToAngle(angle)
switch string(angle)
    case "Right"; angle = deg2rad(0);
    case "Upper Right"; angle = deg2rad(45);
    case "Upper"; angle = deg2rad(90);
    case "Upper Left"; angle = deg2rad(135);
    case "Left"; angle = deg2rad(180);
    case "Lower Left"; angle = deg2rad(225);
    case "Lower"; angle = deg2rad(270);
    case "Lower Right"; angle = deg2rad(315);
end
end