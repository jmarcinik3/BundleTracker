function im = imageToClass(im, toClass)
originalClass = class(im);
if strcmp(toClass, originalClass)
    return;
end

switch toClass
    case "uint8"
        im = im2uint8(im);
    case "uint16"
        im = im2uint16(im);
    case "single"
        im = im2single(im);
    case "double"
        im = im2double(im);
end
end