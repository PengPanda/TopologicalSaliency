function geoRefSal = SelectivePathway(srcImg,segs,frameRecord, RBDprior,OTS_fullsizeSalMap)
%% ====For geometric Saliency in SelectivePathway. (i.e., local cues)==
% input: RGB-saliency prior and OTS map
% output: geoRefSal: local cues saliency
%% ==============================================
addpath('.\GeoFunc\')
%%
priormap = refineImg(NormalizeMap(RBDprior+OTS_fullsizeSalMap),10,0.9);

[sch,scw,~] = size(srcImg);
%% -------reszimg

    [ww,hh,nchns] = size(srcImg);
    if nchns == 1
        srcImg(:, :, 2) = srcImg(:, :, 1);
        srcImg(:, :, 3) = srcImg(:, :, 1);
    end

    if ww>hh
        srcImg = imresize(srcImg,[400 floor(hh*(400/ww))],'bilinear');
    elseif ww<=hh
        srcImg = imresize(srcImg,[floor(ww*(400/hh)) 400],'bilinear');
    end
    resizeImage = srcImg;
    
%%-----------------------------
[rzh,rzw,~] = size(resizeImage);
rszfgSalMap = imresize(priormap,[rzh,rzw]); % ResizedFigureGroundSaliencyMap

%% remove image frame and get superpixels 
noFrameImg = resizeImage(frameRecord(3):frameRecord(4), frameRecord(5):frameRecord(6),:);
noFrame_fgSalMap = rszfgSalMap(frameRecord(3):frameRecord(4), frameRecord(5):frameRecord(6));
[h1, w1,~] = size(noFrameImg);

    newSegs = zeros(h1, w1);
    % remove boundary
    while(sum(segs(:)==0))
        segs = imdilate(segs, strel('disk', 1));
    end
    % remove null superpixels
    numSP = max(segs(:));
    pixellist = cell(numSP, 1);
    numSP1 = 0;
    for spi=1:numSP
        idx = find(segs(:)==spi);
        if numel(idx) ~=0
            numSP1 = numSP1 + 1;
            pixellist{numSP1} =  idx;
            newSegs(idx) = numSP1;
        end
    end
    numSP = numSP1;
    pixellist = pixellist(1:numSP);
    segs = newSegs;       
    
%% -----calculating local cues saliency----------
edgeSalMap1 = GeoRefine(pixellist, segs, noFrameImg, noFrame_fgSalMap);
edgeSalMap1 = invRemoveFrame(edgeSalMap1, frameRecord, rzh, rzw, 0);
edgeSalMap1 = refineImg(edgeSalMap1,10,1);
edgeSalMap1 = imresize(edgeSalMap1,[sch,scw]);
geoRefSal = NormalizeMap(edgeSalMap1);


% figure,imshow(geoRefSal);
% title('georefineMap')
