function [fullSizePriorMap, S_nb,OTS_fullsizeSalMap,frameRecord,resizeImage] = GetPriorMap(srcImg)
%% ----------------------------------------------------------------------
% this function computes the topo-complexity map and OTS map.
%  'OTS_fullsizeSalMap':  without refinement and bias, for saliency
%  detection;
%  'fullSizePriorMap' : with little refinement and bias.   for SOD.
%% ----------------------------------------------------------------
%%
    [ww,hh,nchns] = size(srcImg);
    if nchns == 1
        srcImg(:, :, 2) = srcImg(:, :, 1);
        srcImg(:, :, 3) = srcImg(:, :, 1);
    end

    % resize the image to certain size.
    if ww>hh    
        srcImg = imresize(srcImg,[400 floor(hh*(400/ww))],'bilinear');
    elseif ww<=hh
        srcImg = imresize(srcImg,[floor(ww*(400/hh)) 400],'bilinear');
    end
    resizeImage = srcImg;

%% ------do something preprocessing-----------
[Sots, S_nb,frameRecord] = preprocessing(resizeImage);

%% ---------compute topo-priormap Sots--------------
% [Sots, S_nb,frameRecord] = ppSoftSalDetect(srcImg); % Another work for topological perception theory

%% ----------- calculate Gestalt Saliency map------------
    % normalize the image to [0,1] using min-max normalization.
TopoMap = NormalizeMap(Sots);   

    % compute the dist_map and 
sigma = 100;
[DisMap, ColorMap] = optCalGestSaliency(srcImg, S_nb, sigma, Sots,frameRecord);

ColorMap = NormalizeMap(ColorMap);
DisMap = NormalizeMap(DisMap);

FinalMap = NormalizeMap(TopoMap + DisMap.*TopoMap + DisMap.*ColorMap);
%% ===some refinement ========================================
SpsMap = medfilt2(FinalMap);

FlattenedData = SpsMap(:)'; % normalize
FlattenedData = 1./(1 + exp((0.3 - FlattenedData)*5));% optional
MappedFlattened = mapminmax(FlattenedData, 0, 1); %
SpsMap = reshape(MappedFlattened, size(SpsMap)); 

%% ----------Two kind of OTS maps--------------------------------
    % Sots without bias, mainly for saliency detection, 
    % Topological complexity map;
OTS_fullsizeSalMap = imresize(Sots,[ww hh],'bilinear');

    % Sots with refinement and bias, for SOD
fullSizePriorMap = imresize(SpsMap,[ww hh],'bilinear');   

