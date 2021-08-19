function [forked, notforked] = findforkedmito(vol, trimThr)
    tic;
    cc = bwconncomp(vol);
    x = regionprops3(cc, 'Image', 'SubarrayIdx');
    forked = zeros(size(vol));
    notforked = zeros(size(vol));
    for j=1:size(x,1) 
        cvol = x(j,:).Image;       
        cvol = cvol{1};        
            cvol1 = padarray(cvol,[15 15, 15],0,'both');
            smoothV = smoothmito(cvol1, 5, 0.001, 0.99);
            percent = sum(cvol, 'all') / sum(smoothV, 'all');
            cvol = smoothmito(cvol1, 3, 0.2, 0.8);
            skelvol=imfill(cvol,'holes');
            skel = Skeleton3D(logical(skelvol));
            if trimThr > 0
                [A,node,link] = Skel2Graph3D(skel, trimThr);
                w = size(skel,1);
                l = size(skel,2);
                h = size(skel,3);
                skel = Graph2Skel3D(node, link, w, l, h);
            end
            [A,node,link] = Skel2Graph3D(skel, 0);
            if(size(link,2) > 1 && percent > 0.9)
                forked(cc.PixelIdxList{j}) = 1;
            else
                notforked(cc.PixelIdxList{j}) = 1;
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