%% SET DATA INFO
names = ["fib1-4-3-0.nii", "fib1-0-0-0.nii", "fib1-3-2-1.nii", "fib1-3-3-0.nii"];
suffix = ".nii";
resultsFile = "results12.txt";
saveRes = true;

pathToSeg = "...";
pathToFib = "...";
pathToGT = "...";
%% PARAMETERS
params = {{20, 0, 40, @costFunction4, 0.03, true}, ...
          {10, 0, 30, @costFunction5, 0.02, true, true}};
%% RUN
fileID = fopen(strcat(".\Results\", resultsFile), 'a');
iouThr = [0.3, 0.5, 0.7];
for param = params
    % SET PARAMS
    rotationRange = param{1}{1};
    diskHeightRange = param{1}{2}; 
    maxRadius = param{1}{3};
    costFunction = param{1}{4};    
    stopingThr = param{1}{5};
    overlapZero = param{1}{6};
    startMiddle = param{1}{7};
    for n = names
        % Read volumes
        pSeg = pathToSeg + n;
        pFib = pathToFib + n;
        pGt = pathToGT + n;
        segVolume = niftiread(pSeg);
        fibVolume = niftiread(pFib);
        gt = niftiread(pGt);

        % Remove noise
        segVolumeNoiseRemoved = removeNoise(segVolume, 1000, 200); 
        % Remove components touching border
        %segVolumeNoiseRemoved = imclearborder(segVolumeNoiseRemoved); 

        % Get connected components and its info
        connectedComponents = bwconncomp(segVolumeNoiseRemoved);
        statsCC = regionprops(connectedComponents,'Image', 'SubarrayIdx');

        % Fit disks to volume
        nameDescription = "-rotR-" + rotationRange + "-hR-" + ...
                          diskHeightRange + "-maxR-" + maxRadius + "-" + ...
                          func2str(costFunction) + "-sT-" + stopingThr + ...
                          "-oZ-" + overlapZero + "-sMid-" + startMiddle +  ".mat";

        saveRecName = ".\Output\" + extractBefore(n, suffix) + ...
            "-rec" + nameDescription;
        saveClassName = ".\Output\" + extractBefore(n, suffix) + ...
            "-class" + nameDescription;

        [finalClass, finalRec] = fitFv(fibVolume, statsCC, nameDescription, ...
                                       diskHeightRange, rotationRange, ...
                                       maxRadius, costFunction, ...
                                       saveRecName, saveClassName, ...
                                       stopingThr, overlapZero, ...
                                       startMiddle, saveRes);

        % Save output  
        if (saveRes == true)
            save(saveRecName, 'finalRec');
            save(saveClassName, 'finalClass');
        end

        % Eval results
        description = "Rotation range: " + rotationRange + ...
                      ", Disk height range: " + diskHeightRange + ... 
                      ", Max radius: " + maxRadius + ....
                      ", Cost function: " +  func2str(costFunction) + ...
                      ", Stop threshold: " +  stopingThr + ...
                      ", Overlapzero: " +  overlapZero + ...
                      ", Start middle: " +  startMiddle;

        evalFvReconstruction(fileID, gt, segVolume, finalClass, iouThr, description);
        
    end
end
fclose(fileID);
