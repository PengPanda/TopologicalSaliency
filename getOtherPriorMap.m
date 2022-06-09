function [cenPriorMap, CBSPrior,RBDprior] = getOtherPriorMap(img)
%% otherPriorMap



%%
% clear
% close all
% addpath('testPic\')
addpath(genpath('CGVSsalient\'));
addpath(genpath('RBD\'));
addpath(genpath('RBD\Funs\'));
addpath(genpath('Bayesian'));


% uint8Img = imread('3_100_100396.jpg');
uint8Img = img;
% figure
% imshow(uint8Img)
% title('srcImg')

srcImg = double(uint8Img)./255;

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
% clear ww hh
    Gs = fspecial('gaussian',[6, 6], 8);
    srcImg = imfilter(srcImg,Gs,'replicate'); 
    img = srcImg;





%% centerBias (used in our method)============================
% [sch, scw, ~] = size(srcImg);
% sig = 500; % 500
% cx = floor(scw/2);
% cy = floor(sch/2);
% 
% temp_x = linspace(1,scw,scw);
% temp_y = linspace(1,sch,sch);
% 
% [x, y]=meshgrid(temp_x, temp_y);
% W=exp(-((x-cx).^2+((y-cy).^2)/((sch/scw)^2))./sig.^2);
% 
% cenPriorMap = W.*(ones(sch, scw));
% 
% figure
% imshow(cenPriorMap)
% title('cenPriorMap')

%% Contour-based Spatial Prior (CGVS)=========================
% 
% % edge-based saliency, i.e.,spatial weights
% [ESmap,Edge]= EdgeSaliency(img);
% 
% % extracting local cues, e.g. color,luminance,texture etc.
% sigma = 0.1; 
% cues = getLocalcues(img,sigma,Edge);
% 
% CBSPrior = ESmap; 
% % Wcues = 0.25*ones(1,size(cues,2));
% % 
% % [CBSPrior,~]= ObjMask(prior,cues,Wcues);
% 
% figure
% imshow(CBSPrior)
% title('CBSPrior map')

%% RBD prior (RBD)========================================
doFrameRemoving = true;
useSP = true;  

    srcImg = uint8Img;
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
    
figure
imshow(RBDprior)
title('RBDprior map')

%% Interest Points prior (TIP-2013-Bayesian Saliency via Low and Mid Level Cues)
% 
% IPprior = ppGetSalPrior(uint8Img);
% figure
% imshow(IPprior)
% title('IPprior map')
%%
% if nargout == 1
    cenPriorMap=[];
    CBSPrior=[];
% end