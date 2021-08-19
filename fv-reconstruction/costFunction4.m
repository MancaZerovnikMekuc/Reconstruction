function score = costFunction4(inputVolume, predictedDisks, prevDiskVolume, overlapping)  
    predictedDisks(predictedDisks>1) = 1;
    newOverlap = sum(inputVolume(:) >= 2) / sum(inputVolume(:) >= 1);
    [dsc, ~, ~, ~] = coef(predictedDisks, inputVolume);
    score = 0.5 * (1 - dsc) + newOverlap;
end

function [dsc, tpr, FP, TP] = coef(predicted, groundTruth)
    adder = int8(predicted) + int8(groundTruth);
    TP = length(find(adder == 2));
    subtr = int8(groundTruth) - int8(predicted);
    FP = length(find(subtr == -1));
    FN = length(find(subtr == 1));
    tpr = (TP)/(TP+FP);
    dsc = (2*TP)/(2*TP+FP+FN);
end