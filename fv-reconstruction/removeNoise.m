function vol = removeNoise(bw, minVolume, maxHole)
% 	REMOVENOISE  Remove noise from the input volume. 
%   vol = removenoise(bw, minVolume, maxHole) remove all components smaller
%   than minVolume and remove all holes in the components which are smaller
%   than maxHole int the input volume bw    
    vol = bw;
    % remove small components 
    bw = bwareaopen(bw, minVolume);
    % remove holes
    bw = ~bwareaopen(~bw, maxHole);
    %return vol
    vol(bw==0) = 0;
end