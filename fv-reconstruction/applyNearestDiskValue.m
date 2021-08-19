function [classifiedFv]=applyNearestDiskValue(currentFv, currentDisks)
    labels = unique(currentDisks);
    iFvNew = zeros(size(currentFv));
    for lbl = 1:length(labels)
        if labels(lbl) ~= 0
            currDisk = currentFv;
            currDisk(currentDisks~=labels(lbl)) = 0;
            iFvNew = iFvNew + (currDisk * labels(lbl));
        end
    end
    [D,IDX] = bwdist(currentDisks~=0);
    currentFv(iFvNew>0) = 0;
    nearestValues = currentDisks(IDX);
    nearestValues = (currentFv) .* nearestValues;
    classifiedFv = nearestValues + iFvNew;
end