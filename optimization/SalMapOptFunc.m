function Stops = SalMapOptFunc(srcImg,resizeImg,spMap,frameRecord,fullsizeSalMap, lambda, beta)
%% =====optimization function=========================
% input: sourceImage: srcImg
%        superpixel: spMap
%        noFrameMap: noFrameMap
%        frameRecord: frameRecord
% output: Stops: optimaized Stops
%%==========================================
addpath(genpath('Funcs'));

if nargin ==5
    lambda=20;
    beta = 0.9;
end

%%
spMap= spMap+1;
idxImg = spMap;
[hh, ww, chn] = size(resizeImg);
noFrameImg = [];
for nch =1:chn
    noFrameImg(:,:,nch) = resizeImg(frameRecord(3):frameRecord(4), frameRecord(5):frameRecord(6),nch);
end

fullsizeSalMap = imresize(fullsizeSalMap,[hh,ww],'bilinear');
noFrameSalMap =  fullsizeSalMap(frameRecord(3):frameRecord(4), frameRecord(5):frameRecord(6));

%%
[h, w, ~] = size(noFrameImg);
spIdx = unique(spMap);
spNum = length(spIdx);                     %super-pixel number for current image
%%
adjcMatrix = GetAdjMatrix(idxImg, spNum);

%%
fgSpList = zeros(size(spIdx));
pixelList = cell(spNum, 1);
for n = spIdx' % 1:spNum
    salValue = [];
    pixelList{n} = find(idxImg == n);
    salValue = mean2(noFrameSalMap(pixelList{n}));
    fgSpList(n) = salValue;
    bgSpList(n) = 1- salValue;   
end

%% Get super-pixel properties
spNum = size(adjcMatrix, 1);
meanRgbCol = GetMeanColor(noFrameImg, pixelList);
meanLabCol = colorspace('Lab<-', double(meanRgbCol)/255);
meanPos = GetNormedMeanPos(pixelList, h, w);  %ori: h,w
colDistM = GetDistanceMatrix(meanLabCol);
posDistM = GetDistanceMatrix(meanPos);
[clipVal, geoSigma, neiSigma] = EstimateDynamicParas(adjcMatrix, colDistM);

smLambda = 1; %2
%%optimization
optSalList = salOptimization(adjcMatrix, colDistM, neiSigma, bgSpList, fgSpList,smLambda);

%% recover image size
temp_optSalMap = zeros(h,w);
optSalMap = zeros(hh, ww);
for i = spIdx'
    temp_optSalMap(idxImg == i) = optSalList(i); 
end
optSalMap(frameRecord(3):frameRecord(4), frameRecord(5):frameRecord(6)) = temp_optSalMap;


%% show img
[fw,fh,~] = size(srcImg);

fullSizeOptSalMap = imresize(optSalMap,[fw,fh],'bilinear');
fullSizeOptSalMap = NormalizeMap(fullSizeOptSalMap);

level=graythresh(fullSizeOptSalMap); 
FlattenedData = fullSizeOptSalMap(:)'; % normalize
FlattenedData = 1./(1 + exp((beta*level - FlattenedData)*lambda));%%% optional
MappedFlattened = mapminmax(FlattenedData, 0, 1); % 
Stops = reshape(MappedFlattened, size(fullSizeOptSalMap)); 
