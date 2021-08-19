function [iouL, matchingIdL, iouGT, matchingIdGT]=evaluateReconstruction(volL, volGT)
% [P,R,F1,tpfpL,tpfnGT]=evaluateVolumeLabelsParts(volL, cDataL, volGT, cDataGT)
% evaluates the accuracy of labelled vs ground truth data. Evaluates according to connected components.
% P,R,F1 are self explainable
% tpfpL contains [1 gtlabel label] for true positives, and [2 gtlabel label] for false positive
% tpfnGT contains [1 gtlabel label] for true positives, and [2 gtlabel label] for false negatives

%%%NOTES:
%In COCO, if you look at their source code, they rank all the detections based on the scores from high to low, and then cut off the results at the maximum number of detections allowed. For each detection, the algorithm iterates through all ground truth, and the previously unmatched ground truth with the highest IoU is matched with the detection.
%In CityScapes, for each ground truth, the algorithm iterates through all predictions that have non-zero intersection with it. When there are more than one predictions matched with the same ground truth, the ones with the lower score are automatically set as false positive. IoU is only used to decide if it passes the threshold.

%We will implement the one by COCO but it will be voxelwise

% labelled data
idsL = unique(volL);
iouL = zeros(size(idsL));
matchingIdL = zeros(size(idsL));

% ground truth
idsGT = unique(volGT);
iouGT = zeros(size(idsGT));
matchingIdGT = zeros(size(idsGT));

%for every labelled component find matching gt
for i=1:length(idsL)
    i
    currentLId = idsL(i);
    currentLindices = find(volL==currentLId);
    %go trough every nonmatched gt
    bestIou = 0;
    bestId = 0;
    for j=1:length(idsGT)
        if mod(j,20) == 0
            fprintf("%d ",j);
        end
        %fprintf("%d ",j);
        if matchingIdGT(j) == 0
            currentGTId = idsGT(j);
            currentGTIndices = find(volGT==currentGTId);
            overlap = intersect(currentLindices,currentGTIndices);
            all = union(currentLindices,currentGTIndices);
            iou = size(overlap,1)/size(all,1);
            if iou > bestIou
                bestIou = iou;
                bestId = j;
            end
        end
    end
    if bestIou ~= 0
        matchingIdGT(bestId) = i;
        iouGT(bestId) = bestIou;
        iouL(i) = bestIou;
        matchingIdL = idsGT(bestId);
    end
end
end
%% 
% 
% 
% 
% 
% tp=[0 0];
% fp=[0 0];
% fn=[0 0];
% 
% 
% %tpfpL=zeros(cDataL.NumObjects,3);
% %tpfnGT=zeros(cDataGT.NumObjects,3);
% 
% % size of labelled components
% ccLSizes=zeros(1,cDataL.NumObjects);
% for i=1:cDataL.NumObjects
%   pl=volGT(cDataL.PixelIdxList{i});
%   ccLSizes(i)=nnz(pl~=-1);
% end
% 
% volcc=uint32(volL); % indices of labelled components (for counting false positives)
% for i=1:cDataL.NumObjects
%   volcc(cDataL.PixelIdxList{i})=i;
% end
% 
% % first over ground truth
% for i=1:cDataGT.NumObjects
%   %lbl=cDataGT(i).type;!!!!!!!!!!!!!!!!!!!!!!
%   lbl = 1;
%   %maska = zeros(256,256,256);
%   %maska(cDataGT.PixelIdxList{i}) = 1;
%   coverage=volL(cDataGT.PixelIdxList{i});
%   pl=(coverage==lbl);
%   
%   %if (nnz(cDataGT.PixelIdxList{i})>800) % min size of GT part to consider in evaluation
%     if nnz(pl)/length(cDataGT.PixelIdxList{i})>0.97    % if at least half of voxels match in label
%       tpfnGT(i,:)=[1 lbl lbl];  % 1 means true positive
%       tp(lbl)=tp(lbl)+1;
%     else
%       %gtV = maska*volGT;
%       %lbV = maska*volL;s
%       %zzzz = cDataGT.Image{i};
% 
%       [~,b]=max(hist(coverage,[0 1 2]));
%       tpfnGT(i,:)=[2 lbl b-1]; % 2 means false negative (was present in GT, but mislabelled)
%       fn(lbl)=fn(lbl)+1;
%     end
%   %end
%   
%   %% counter for false positives - remamining voxels (not covered by GT)
%   cp=volcc(cDataGT.PixelIdxList{i}(pl));
%   for j=unique(cp)'
%     ccLSizes(j)=ccLSizes(j)-nnz(cp==j);
%   end 
% end
% 
% for i=1:cDataL.NumObjects
%   %WHY THIS!!!!!!
%   %if (cDataL(i).gtLabel==-1) % if no GT label, skip
%   %!!!!!!!!!!!!!!!!!!!!!!!!!!
%   %  continue;
%   %end
%   pl=volGT(cDataL.PixelIdxList{i});
%   %if nnz(pl~=-1)<500 % if too few labelled voxels, skip
%   %  continue;
%   %end
%   [~,b]=max(hist(double(pl(pl~=-1)),[0 1 2]));
%   lblgt=b-1;
%   if ccLSizes(i)/nnz(pl~=-1)>0.3 % if over 1/3 of voxels were not covered by GT, label as false positive
%     [~,b]=max(hist(volL(cDataL.PixelIdxList{i}(pl~=-1)),[0 1 2]));
%     lbl=b-1;
%     fp(lbl)=fp(lbl)+1;
%     tpfpL(i,:)=[2 lblgt lbl]; % 2 means false positive
%     %disp([i lbl  double(median(pl(pl~=-1))) nnz(pl~=-1) ]);
%   else
%     tpfpL(i,:)=[1 lblgt lblgt]; % otherwise label as true positive, but dont count it into tp, as it was already counted before
%   end
% end
% tpVOL = zeros(size(volGT));
% fpVOL = zeros(size(volGT));
% fnVOL = zeros(size(volGT)); %gt - tp
% numOfTP = 0;
% numOfFP = 0;
% notfoundGT = ones(1, cDataGT.NumObjects);
% for i=1:cDataL.NumObjects
%     found = 0;
%     for j=1:cDataGT.NumObjects
%         intr = intersect(cDataGT.PixelIdxList{j}, cDataL.PixelIdxList{i});
%         if(size(intr,1) > (size(cDataGT.PixelIdxList{j},1) * 0.8))
%             tpVOL(cDataL.PixelIdxList{i}) = 1;
%             numOfTP = numOfTP+1;
%             notfoundGT(j) = 0;
%             found = 1;
%             break;
%         end
%     end
%     if(found == 0)
%         fpVOL(cDataL.PixelIdxList{i}) = 1;
%         numOfFP = numOfFP + 1;
%     end
% end
% for j=1:cDataGT.NumObjects
%     if(notfoundGT(j) == 1)
%         fnVOL(cDataGT.PixelIdxList{j})=1;
%     end
% end
%         
% disp("NUMOFEL");
% disp(cDataL.NumObjects);
% disp("TP");
% disp(numOfTP);
% disp("FP");
% disp(numOfFP);
% disp("NOT FOUND");
% disp(sum(notfoundGT));
% P=tp./(tp+fp);
% R=tp./(tp+fn);
% F1=2*P.*R./(P+R);
% 
% %if nargout==0
%   %disp([P R F1 tp fp fn]);
% %end