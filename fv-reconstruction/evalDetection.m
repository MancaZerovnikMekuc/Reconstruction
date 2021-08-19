function [tpVOL, fpVOL, fnVOL, TP, FP, nfound]=evaldetection(volL, volGT, evalTreshold, binaryGT, binarySEG)
% EVALDETECTION is a function evaluating detection
% [tpVOL, fpVOL, fnVOL, TP, FP, nfound]=evaldetection(volL, volGT, evalTreshold)
% volL should be a binary volume representing segmentation which we want to
% evaluate
% volGT should be ground truth volume, where each object has distinct
% integer as a label (in the function we remove all the objects smalle
% rthan 5 voxels because of possible noise in GT).
% evalTreshold is a value used for jaccard index evaluation. if overlapping
% of two objects is higher than the treshold than object is trated as true
% positive.
% Return values are number of true positive objects (TP), false positive
% objects (FP) and not found objects (nfound).
% The function returns volumes for visualisation of results tpVOL is volume
% of truepositive objects, fpVOL is a volume which contains all the false
% positive objects (objeccts which shouldn't be found), fnVOL is a volume 
% which consists of false negative objects (it is showing objects from GT 
% which where not found).
    if binarySEG
        [volL, cDataL] = preparedatawithsegmentationlabels(volL);
    else
        [volL, cDataL] = preparedatawithdetectionlabels(volL);
    end
    if binaryGT
        [volGT, cDataGT] = preparedatawithsegmentationlabels(volGT);
    else
        [volGT, cDataGT] = preparedatawithdetectionlabels(volGT);
    end
    tpVOL = zeros(size(volGT));
    fpVOL = zeros(size(volGT));
    fnVOL = zeros(size(volGT)); %gt - tp
    TP = 0;
    FP = 0;
    notfoundGT = ones(1, cDataGT.NumObjects);
    foundGT = zeros(cDataGT.NumObjects, 2);
    
    indxs = ones(1, cDataL.NumObjects);
    
    while sum(indxs) > 0
        sum(indxs)
        i = find(indxs,1,'first');
        i
        found = 0;
        for j=1:cDataGT.NumObjects
            intr = intersect(cDataGT.PixelIdxList{j}, cDataL.PixelIdxList{i});         
            %if(size(intr,1) > (size(cDataGT.PixelIdxList{j},1) * evalTreshold))
            uni = union(cDataGT.PixelIdxList{j}, cDataL.PixelIdxList{i});
            size(intr,1)/size(uni,1);
            if(size(intr,1)/size(uni,1) > evalTreshold)
                if(notfoundGT(j) <= 0)
                    %if previous finding was better go on with the loop
                    if foundGT(j,2) > size(intr,1)/size(uni,1)
                        continue;
                    else
                        %if this one is better replace previous one
                        replaceIndex = foundGT(j,1);
                        tpVOL(cDataL.PixelIdxList{replaceIndex}) = 0;
                        TP = TP - 1;
                        notfoundGT(j) = notfoundGT(j) + 1;
                        indxs(replaceIndex) = 1;
                    end
                end
                foundGT(j,1) = i;
                foundGT(j,2) = size(intr,1)/size(uni,1);                
                tpVOL(cDataL.PixelIdxList{i}) = 1;
                TP = TP+1;
                notfoundGT(j) = notfoundGT(j) - 1;
                found = 1;
                indxs(i) = 0;
                break;
            end
        end
        if(found == 0)
            fpVOL(cDataL.PixelIdxList{i}) = 1;
            FP = FP + 1;
            indxs(i) = 0;
        end
    end
    for j=1:cDataGT.NumObjects
        if(notfoundGT(j) == 1)
            fnVOL(cDataGT.PixelIdxList{j})=1;
        end
    end
    nfound = sum(notfoundGT);
    if (size(unique(notfoundGT),2) > 2) 
        warning("GT counted twice")
    end
    if (nfound + TP) ~= cDataGT.NumObjects
        warning("something's not right")
    end
end


function [gt, gtc]=preparedatawithdetectionlabels(gt)
    pixl = regionprops(gt, 'PixelIdxList', 'Image', 'PixelList');
    gtc = {};
    gtc.NumObjects = size(pixl,1);
    gtc.PixelIdxList = {};
    gtc.Image = {};
    gtc.PixelList = {};
    numOfElements = 1;
    for i=1:gtc.NumObjects
        if size(pixl(i).PixelIdxList,1) > 5
            gtc.PixelIdxList{numOfElements} = pixl(i).PixelIdxList;
            gtc.Image{numOfElements} = pixl(i).Image;
            gtc.PixelList{numOfElements} = pixl(i).PixelList;
            numOfElements = numOfElements + 1;       
        end
    end    
    gtc.NumObjects = numOfElements-1;
    gt(gt>1) = 1;
end
function [vol, volc]=preparedatawithsegmentationlabels(vol)
    volc = bwconncomp(vol);
end