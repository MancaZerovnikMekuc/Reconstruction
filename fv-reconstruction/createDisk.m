function [outputDiskVolume, finalOutput, overlapping]=createDisk(radius, inputImage,...
    finalOutput, overlapping, counter, rotation1, rotation2, xCenter, yCenter, zCenter, width, overlapZero)
    
    diskSize = radius * 2;
    [columnsInImage, rowsInImage] = meshgrid(1:diskSize, 1:diskSize);
    circlePixels = (rowsInImage - radius).^2 + (columnsInImage - radius).^2 <= radius.^2;
    circlePixels = reshape(circlePixels, [], size(circlePixels,1), size(circlePixels,2));
    diskVolume = [];
    for j=1:width
        diskVolume = [diskVolume; circlePixels];
    end
    diskVolume = imrotate3(diskVolume, rotation1, [0 0 1],'nearest','loose','FillValues',0);
    diskVolume = imrotate3(diskVolume, rotation2, [1 0 0],'nearest','loose','FillValues',0);
    
    % get coordinates for putting disk in output volume
    s1 = round(size(diskVolume, 2) / 2);
    s11 = s1 - round(mod(size(diskVolume, 2)/2, 1));
    s2 = round(size(diskVolume, 1) / 2);
    s22 = s2 - round(mod(size(diskVolume, 1)/2, 1));
    s3 = round(size(diskVolume, 3) / 2);
    s33 = s3 - round(mod(size(diskVolume, 3)/2, 1));
    xIndices = (xCenter - s1 + 1) : (xCenter + s11);
    yIndices = (yCenter - s2 + 1) : (yCenter + s22);
    zIndices = (zCenter - s3 + 1) : (zCenter + s33);
    
    % put created disk in the output volume
    outputDiskVolume = inputImage;
    outputDiskVolume(yIndices, xIndices, zIndices) = ...
        outputDiskVolume(yIndices, xIndices, zIndices) + diskVolume;
    overlapping(outputDiskVolume > 1) = 1;
    if counter ~= 0
        % Create output reconstruction with unique labels for each disk
        % If the disks are overlapping set voxels to current disk
        finalOutput(yIndices, xIndices, zIndices) = ...
            finalOutput(yIndices, xIndices, zIndices) + diskVolume * counter;
        if overlapZero == 1
            finalOutput(finalOutput > counter) = 0;
        else
            finalOutput(finalOutput > counter) = counter;
        end
        
    end
end