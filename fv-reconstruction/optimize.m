function [outputVolume,v]=optimize(v, heightRange, rotRange, maxRadius, ...
    costFunction, stopingThr, overlapZero, startMiddle)
    % Optimizing parameters for disk:
    %   - Radius
    %   - Center (x, y, z)
    %   - Height
    %   - IntialRotation
    
    % Radius
    minRadius = round((size(v, 2) / 2) * 0.4);
    maxRadiusSmaller = round(size(v, 2) / 2) + 5;
    maxRadius = min(maxRadiusSmaller, maxRadius);
    if(minRadius > maxRadius)
        minRadius = maxRadius / 2;
    end
    
    % Set padding so that bigger circles will not be out of bounds
    paddingSize = max(maxRadius + 20, 2 * maxRadius);
    
    % Center    
    xCenter = round(size(v, 2) / 2) + paddingSize;
    zCenter = round(size(v, 3) / 2) + paddingSize;   
    yCenter = round(size(v, 1) / 2) + paddingSize;   
    if ~startMiddle
        % yCenter - defined as the lowest nonzero voxel in seg volume
        [r,~,~] = ind2sub(size(v),find(v == 1));
        yCenter = min(r)+ paddingSize;
    end


    
    xCenterRange = (size(v, 2)) * 0.5;
    yCenterRange = 10;
    zCenterRange = (size(v, 3)) * 0.5;
    
    lowerBoundXCenter = max(1, xCenter - xCenterRange);
    lowerBoundYCenter = max(1, yCenter - yCenterRange);
    lowerBoundZCenter = max(1, zCenter - zCenterRange);
    
    upperBoundXCenter = xCenter+xCenterRange;
    upperBoundYCenter = yCenter + yCenterRange;
    upperBoundZCenter = zCenter + zCenterRange;
    
    % Height
    height = 4;
    
    % IntialRotation
    rotationRange = rotRange;    
    intialRotation = 0;
    
    % Pad volume with zeros
    v = padarray(v, [paddingSize, paddingSize, paddingSize], 0, 'both');
    
    % Starting point
    X0 = [(maxRadius + minRadius) / 2, intialRotation, intialRotation, ...
        height xCenter yCenter zCenter];   
    
    % Lower bound
    LB = [minRadius, -rotationRange, -rotationRange, height-heightRange, ...
        lowerBoundXCenter, lowerBoundYCenter, lowerBoundZCenter];   
    % Upper bound
    UB = [maxRadius, rotationRange, rotationRange, height+heightRange, ...
        upperBoundXCenter, upperBoundYCenter, upperBoundZCenter]; 
    
    % Add disks while cost is decreasing
    diskVolume = zeros(size(v));
    overlapping = zeros(size(v));
    outputVolume = zeros(size(v));
    prevOutputVolume = outputVolume;
    firstIter = 1; isBetter = 1; count = 1;

    while(isBetter)
        f = @(x)objectiveFun(x, v, diskVolume, overlapping, costFunction, overlapZero);        
        tic
        [x,fval] = patternsearch(f,X0,[],[],[],[],LB,UB); 
        toc
        
        fprintf("%d: %.4f\n", count, fval);
        
        % Update X0
        X0(2) = x(2);
        X0(3) = x(3);
        X0(5) = round(x(5));
        X0(6) = round(x(6));
        X0(7) = round(x(7));        
        % Update lower bound
        LB(2) = x(2) - rotationRange;
        LB(3) = x(3) - rotationRange; 
        %LB(6) = x(6) - yCenterRange;
        % Update upper bound
        UB(2) = x(2) + rotationRange;
        UB(3) = x(3) + rotationRange; 
        %UB(6) = x(6) + yCenterRange;
    
        % Create disk
        [diskVolume, outputVolume, overlapping] = createDisk( ...
            round(x(1)), diskVolume, outputVolume, overlapping, count,...
            x(2), x(3), round(x(5)), round(x(6)), round(x(7)), round(x(4)), ...
            overlapZero);
        
        % Check if we still improve cost
        if (firstIter ~= 1)
            if(fval >= prevfval || (prevfval - fval) < stopingThr)
                isBetter = 0;
                diskVolume = prevDiskVolume;
                outputVolume = prevOutputVolume;
                fval = prevfval;
            end
        end
        
        prevfval = fval;
        prevDiskVolume = diskVolume;
        prevOutputVolume = outputVolume;
        firstIter = 0;
        count = count + 1;
    end
end