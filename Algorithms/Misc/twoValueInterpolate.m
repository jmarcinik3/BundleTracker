function yinterp = twoValueInterpolate(array, index, zeroValue)
indexFloor = floor(index);
isExact = indexFloor == index;
yFloor = array(indexFloor);

if isExact
    yinterp = yFloor;
else
    indexCeiling = ceil(index);
    indexProportion = index - indexFloor;
    yCeiling = array(indexCeiling);
    y = [yFloor, yCeiling];
    yinterp = interp1([0, 1], y, indexProportion);
end
end
