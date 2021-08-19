function score = costFunction2(inputVolume, predictedDisks, prevDiskVolume, overlapping)
    
    predictedDisks(predictedDisks>1) = 1;
    [dsc, tpr, ~, ~] = coef(predictedDisks, inputVolume);
    
    score = 0.3 *(1 - tpr)  +...
        0.3 * (sum(overlapping, 'all') / sum(predictedDisks, 'all')) + 0.2 * (1 - dsc);
end

function [dsc, tpr, FP, TP] = coef(predicted, groundTruth)
    adder = int8(predicted) + int8(groundTruth);
    TP = length(find(adder == 2));
    TN = length(find(adder == 0));
    subtr = int8(groundTruth) - int8(predicted);
    FP = length(find(subtr == -1));
    FN = length(find(subtr == 1));
    tpr = (TP)/(TP+FP);
    dsc = (2*TP)/(2*TP+FP+FN);
end