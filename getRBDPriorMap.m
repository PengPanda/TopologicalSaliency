function RBDprior = getRBDPriorMap(srcImg)

addpath(genpath('RBD\'));
addpath(genpath('RBD\Funs\'));

%     srcImg = double(uint8Img)./255;
%     [ww,hh,nchns] = size(srcImg);
%     if nchns == 1
%         srcImg(:, :, 2) = srcImg(:, :, 1);
%         srcImg(:, :, 3) = srcImg(:, :, 1);
%     end

%% RBD prior (RBD)========================================
doFrameRemoving = true;
useSP = true;  

    if size(srcImg,3) == 1
        srcImg(:, :, 2) = srcImg(:, :, 1);
        srcImg(:, :, 3) = srcImg(:, :, 1);
    end
    
    
    if doFrameRemoving
        [noFrameImg, frameRecord] = removeframeRBD(srcImg, 'sobel');
        [h, w, ~] = size(noFrameImg);
    else
        noFrameImg = srcImg;
        [h, w, chn] = size(noFrameImg);
        frameRecord = [h, w, 1, h, 1, w];
    end
    
    % Segment input rgb image into patches (SP/Grid)
    pixNumInSP = 600;                           %pixels in each superpixel
    spnumber = round( h * w / pixNumInSP );     %super-pixel number for current image
    
    if useSP
        [idxImg, adjcMatrix, pixelList] = SLIC_Split(noFrameImg, spnumber);
    else
        [idxImg, adjcMatrix, pixelList] = Grid_Split(noFrameImg, spnumber);        
    end
    %% Get super-pixel properties
    spNum = size(adjcMatrix, 1);
    meanRgbCol = GetMeanColor(noFrameImg, pixelList);
    meanLabCol = colorspace('Lab<-', double(meanRgbCol)/255);
    meanPos = GetNormedMeanPos(pixelList, h, w);
    bdIds = GetBndPatchIds(idxImg);
    colDistM = GetDistanceMatrix(meanLabCol);
    posDistM = GetDistanceMatrix(meanPos);
    [clipVal, geoSigma, neiSigma] = EstimateDynamicParas(adjcMatrix, colDistM);
    
    %% Saliency Optimization
    [bgProb, bdCon, bgWeight, fgProb] = EstimateBgProb(colDistM, adjcMatrix, bdIds, clipVal, geoSigma);
    smapName = 'unused';
    RBDprior = SaveSaliencyMapPP(fgProb, pixelList, frameRecord, smapName, true);
    
% figure
% imshow(RBDprior)
% title('RBDprior map')
