function score = costFunction6(inputVolume, predictedDisks, prevDiskVolume, overlapping)  
    
    %newOverlap = sum(predictedDisks(:) >= 2) / sum(predictedDisks(:) >= 1);
    %predictedDisks(predictedDisks>1) = 1;
    [dsc, ~, ~, ~] = coef(predictedDisks, inputVolume);
    %score = 0.3 * (1 - dsc) + 0.7 * newOverlap; dobra za 8 in 13 v bistvu
    %je bil overlap vedno 0 pri zgornji verziji!!!
    score = (1 - dsc);
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