function [finalClass,finalRec] = fitFv(fibVolume, statsCC, ...
    description, rrange, rotrange, maxr, costFunction, ... 
    saveRecName, saveClassName, stopingThr, overlapZero, startMiddle, ...
    saveRes)
    
    % initialize output volumes
    finalRec = zeros(size(fibVolume));
    finalClass = zeros(size(fibVolume));
    
    % starting label
    currLabel = 1;    
    
    % go through every connected component
    for i=1:size(statsCC,1)       
        % take component from segmentation and from FIB
        iFvComponent =  statsCC(i).Image;
        iFibComponent = fibVolume(statsCC(i).SubarrayIdx{:});
        
        fprintf("current i: %d, ", i);
        fprintf("size: %d %d %d\n", size(iFvComponent, 1), ...
            size(iFvComponent, 2), size(iFvComponent, 3));
        
        % rotate component so that circle is parallel to XZ plane
        [segRotated, ~, rot1, rot2, skip] = rotateFvStack(iFvComponent, iFibComponent);
        if skip
            continue;
        end
        segRotated(segRotated>0) = 1;
     
        % fit disks to segRotated
        [diskVolume, segRotated] = optimize(segRotated, rrange, rotrange, ...
            maxr, costFunction, stopingThr, overlapZero, startMiddle);

        % rotate disk back to the original rotation of FV
        % doing this label by label, because imrotate3 put too much noise to
        % labels
        for label=1:max(max(max(diskVolume)))
            d = diskVolume;
            d(d~=label) = 0;
            diskVolumeRot = imrotate3(d, -rot2, [0, 0, 1]);
            diskVolumeRot = imrotate3(diskVolumeRot, -rot1, [0, 1, 0]);
            diskVolumeRot(diskVolumeRot>0) = 1;
            if label==1
                allDiskVolumeRot = diskVolumeRot * currLabel;
                currLabel = currLabel + 1;
            else
                allDiskVolumeRot = allDiskVolumeRot + (diskVolumeRot*currLabel);
                allDiskVolumeRot(allDiskVolumeRot>currLabel)=0;
                currLabel = currLabel + 1;
            end
        end
        if sum(diskVolume, 'all') > 0
            % trim volume to the original size or enlarge if needed
            sizeDiff = size(allDiskVolumeRot) - size(iFvComponent);    
            dim1 = round(sizeDiff(1)/2);
            dim1a = dim1;
            if mod(sizeDiff(1) , 2) == 1
                dim1a = dim1a - 1;
            end
            dim2 = round(sizeDiff(2)/2);
            dim2a = dim2;
            if mod(sizeDiff(2) , 2) == 1
                dim2a = dim2a - 1;
            end
            dim3 = round(sizeDiff(3)/2);
            dim3a = dim3;
            if mod(sizeDiff(3) , 2) == 1
                dim3a = dim3a -1 ;
            end
            %enlarge
            if dim1 < 0
                allDiskVolumeRot = padarray(allDiskVolumeRot, [abs(dim1), 0, 0], 0, 'both');
                dim1 = 0;
            end
            if dim2 < 0 
                allDiskVolumeRot = padarray(allDiskVolumeRot, [0, abs(dim2), 0], 0, 'both');
                dim2 = 0;
            end
            if dim3 < 0
                allDiskVolumeRot = padarray(allDiskVolumeRot, [0, 0, abs(dim3)], 0, 'both');
                dim3 = 0;
            end
            % trim
            allDiskVolumeRot = allDiskVolumeRot(dim1+1:end-dim1a, dim2+1:end-dim2a, dim3+1:end-dim3a);
            
            if sum(allDiskVolumeRot, 'all') > 0
                % obtain classification from reconstruction
                classifiedFv = applyNearestDiskValue(iFvComponent, allDiskVolumeRot);

                % add component to final volume
                finalRec(statsCC(i).SubarrayIdx{:}) = ...
                    finalRec(statsCC(i).SubarrayIdx{:}) + ...
                    allDiskVolumeRot;

                finalClass(statsCC(i).SubarrayIdx{:}) = ...
                    finalClass(statsCC(i).SubarrayIdx{:}) + ...
                    classifiedFv;

                % save intermediate result
                if (saveRes == true)
                    save(saveClassName, 'finalClass');
                    save(saveRecName, 'finalRec');
                end
            end
        end
    end
end