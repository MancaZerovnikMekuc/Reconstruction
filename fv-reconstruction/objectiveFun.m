function score = objectiveFun(parameters, v, diskVolume, overlapping, costFunction, overlapZero)    
    maxR = round(parameters(1));
    rotation1 = parameters(2);
    rotation2 = parameters(3);
    width = round(parameters(4));
    x = round(parameters(5));
    y = round(parameters(6));
    z = round(parameters(7));
    prevDiskVolume = diskVolume;
    [diskVolume, ~, overlapping] = createDisk(maxR, diskVolume, diskVolume,overlapping, 0, ...
        rotation1, rotation2, x, y, z, width, overlapZero);
    score = costFunction(v, diskVolume, prevDiskVolume, overlapping);