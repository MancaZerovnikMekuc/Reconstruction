function [volumeRotated, fibRotated, rotation1, rotation2, skip] = rotateFvStack(segVolume, fibVolume)
    %get edges from volume
    edgeVolume = edge3(fibVolume,'sobel', 0.01);
    edgeVolume = edgeVolume.*segVolume; 
    
    %%%%%%%%%%%% FIRST ROTATION    
    % take middle slice to find orientation - startingImage
    startingSlice = round(size(edgeVolume,1)/2);
    startingImage = squeeze(edgeVolume(startingSlice, :,:));
    %find line
    line = houghTransformLines(startingImage); 
    
    %check for lines if no lines break and set skip to true
    skip = false;
    if size(line,2) == 0
        volumeRotated = 0;
        fibRotated = 0;
        rotation1 = 0;
        rotation2 = 0;
        skip = true;
        return;
    end
    
    %take only first line
    line=line(1);    
    %plotlines(line, startingImage);

    %get three points and find angles
    Ax = line.point1(1);
    Ay = line.point1(2);
    Bx = line.point2(1);
    By = line.point2(2);
    if(line.point1(1) > line.point2(1))
        Bx = line.point1(1);
        By = line.point1(2);
        Ax = line.point2(1);
        Ay = line.point2(2);
    end    
    dx = Bx - Ax;
    dy = By - Ay;
    normal = [-dy dx];
    angle = rad2deg(atan2(abs(normal(1)), normal(2)));    
    if(By < Ay)
        firstRotationSegVolume = imrotate3(int8(segVolume), -angle, [0, 1, 0]);
        firstRotationEdgeVolume = imrotate3(edgeVolume, -angle, [0, 1, 0]);
        firstRotationFibVolume = imrotate3(fibVolume, -angle, [0, 1, 0]);
        rotation1 = -angle;
    else
        firstRotationSegVolume = imrotate3(int8(segVolume), angle, [0, 1, 0]);
        firstRotationEdgeVolume = imrotate3(edgeVolume, angle, [0, 1, 0]);
        firstRotationFibVolume = imrotate3(fibVolume, angle, [0, 1, 0]);
        rotation1 = angle;
    end
    %%%%%%%%%%%%%%%SECOND ROTATION
    % take slice
    %this is new - new starting slice here 
    startingSlice = round(size(edgeVolume,3)/2);
    startingImage = squeeze(firstRotationEdgeVolume(:, :,startingSlice));
    
    % find slice with at least 50 nonzero voxels
    % otherwise take a slice with the highest number of nonzero pixels
    maxc = nnz(startingImage);
    best = startingSlice;
    notfound = 0;
    while(nnz(startingImage) < 50)
        startingSlice =startingSlice + 5;
        if(size(firstRotationEdgeVolume,3) < startingSlice) 
            notfound = 1; 
            break; 
        end
        if(nnz(startingImage) > maxc)
            best = startingSlice;
        end
        startingImage = squeeze(firstRotationEdgeVolume(:, :,startingSlice));
    end
    if notfound == 1
        startingImage = squeeze(firstRotationEdgeVolume(:, :,best));
    end
    
    %find line
    line = houghTransformLines(startingImage);
    %take only first line (why are there more)???
    if size(line,2) == 0
        volumeRotated = 0;
        fibRotated = 0;
        rotation1 = 0;
        rotation2 = 0;
        skip = true;
        return;
    end
    line=line(1);
    %plotlines(line, startingImage);
    
    Ax = line.point1(1);
    Ay = line.point1(2);
    Bx = line.point2(1);
    By = line.point2(2);
    if(line.point1(1) > line.point2(1))
        Bx = line.point1(1);
        By = line.point1(2);
        Ax = line.point2(1);
        Ay = line.point2(2);
    end
    dx = Bx - Ax;
    dy = By - Ay;
    normal = [-dy dx];
    angle = rad2deg(atan2(abs(normal(1)), normal(2)));
    if(By < Ay)
        secondRotationSegVol = imrotate3(firstRotationSegVolume, -angle, [0, 0,1]);
        secondRotationFibVolume = imrotate3(firstRotationFibVolume, -angle, [0, 0, 1]);
        rotation2 = -angle;
    else
        secondRotationSegVol = imrotate3(firstRotationSegVolume, angle, [0, 0,1]);
        secondRotationFibVolume = imrotate3(firstRotationFibVolume, angle, [0, 0, 1]);
        rotation2 = angle;
    end
    volumeRotated = secondRotationSegVol;
    fibRotated = secondRotationFibVolume;
end

function lines=houghTransformLines(BW)
    [H,T,R] = hough(BW);
    P  = houghpeaks(H,1, 'Threshold', 0.7*max(H(:)));
    lines = houghlines(BW,T,R,P, 'FillGap',15,'MinLength',5);
end

function plotLines(lines, BW)
    figure, imshow(BW), hold on
    for k = 1:length(lines)
       xy = [lines(k).point1; lines(k).point2];
       plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
       % Plot beginnings and ends of lines
       plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
       plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
    end
end