function [narrow, notnarrow] = findnarrowmito(vol, threshold)
    tic
    cc = bwconncomp(vol);
    x = regionprops3(cc, 'Image', 'SubarrayIdx');
    narrow = zeros(size(vol));
    notnarrow = zeros(size(vol));
    for j=1:size(x,1) 
        cvol = x(j,:).Image;       
        cvol = cvol{1};         
        cvol1 = padarray(cvol,[15 15, 15],0,'both');            
        cvol = smoothmito(cvol1, 3, 0.2, 0.8);
        skelvol=imfill(cvol,'holes');
        skel = Skeleton3D(logical(skelvol));
        distance = bwdist(~skelvol);
        skeldist = distance.*skel;
        skelcc = bwconncomp(skel);
        skel2 = skel;
        skel2(skeldist<threshold) = 0;
        skelcc2 = bwconncomp(skel2);
        num2 = skelcc2.NumObjects;
        num1 = skelcc.NumObjects;
        for c = 1:skelcc2.NumObjects
            if size(skelcc2.PixelIdxList{c},1) < 5
                num2 = num2 - 1;
            end
        end
        for c = 1:skelcc.NumObjects
            if size(skelcc.PixelIdxList{c},1) < 5
                num1 = num1 - 1;
            end
        end                               
        if num2 > num1
             narrow(cc.PixelIdxList{j}) = 1;
        else
            notnarrow(cc.PixelIdxList{j}) = 1;
        end
    end
    toc
end

function s=smoothmito(segV, b, t1, t2)
    segV = smooth3(segV, 'box', b);
    trsh = t1;
    segV(segV(:,:) > trsh) = 1;
    segV(segV(:,:) <= trsh) = 0;
    segV = smooth3(segV, 'box', b);
    trsh = t2;
    segV(segV(:,:) > trsh) = 1;
    segV(segV(:,:) <= trsh) = 0;
    s=segV;
end