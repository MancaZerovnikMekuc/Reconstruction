v1 = load('finalClassification2highonly4.mat');
v1 = v1(1).finalClassification;

v2 = load('finalReconstruction2highonly4.mat');
v2 = v2(1).finalReconstruction;

showByLabel = 0;
showByCC = 1;

if showByCC
    ccc = bwconncomp(v1);
    vol = v1;
    stats = regionprops(ccc,'Image', 'SubarrayIdx');
    for i = 1:ccc.NumObjects
        current =  v1(stats(i).SubarrayIdx{:}) .* stats(i).Image;
        currentDisks =  v2(stats(i).SubarrayIdx{:});
        un = unique(current)
        label = 1;
        for j=un(2):max(un)
            current(current==j) = label;
            label = label + 1;
        end
        label = 1;
        un2 = unique(currentDisks);
        for j=un2(2):max(un2)
            currentDisks(currentDisks==j) = label;
            label=label+1;
        end
        volumeViewer(current+currentDisks);
        volumeViewer close
    end
end

if showByLabel
    for i=1:max(max(max(v1)))
        tmp = v1;
        tmp(tmp~=i) = 0;
        volumeViewer(tmp);
        close all;
    end
end