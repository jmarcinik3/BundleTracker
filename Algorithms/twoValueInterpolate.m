function yinterp = twoValueInterpolate(array, index, zeroValue)
indexFloor = floor(index);
isExact = indexFloor == index;

if indexFloor <= 0
    yFloor = zeroValue;
else
    yFloor = array(indexFloor);
end

if isExact
    yinterp = yFloor;
else
    indexCeiling = min(ceil(index), numel(array));
    indexProportion = index - indexFloor;
    yCeiling = array(indexCeiling);
    y = [yFloor, yCeiling];
    yinterp = interp1([0, 1], y, indexProportion);
end
end
