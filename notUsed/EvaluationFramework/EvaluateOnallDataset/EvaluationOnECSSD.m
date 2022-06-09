function EvaluationOnECSSD(FTSDir,optFTSDir,OTSDir)

addpath(genpath('..\'));
addpath(genpath('EdgeDetection\'));
addpath(genpath('optimization\'));

if ~exist(FTSDir, 'dir')
    mkdir(FTSDir);
end
if ~exist(optFTSDir, 'dir')
    mkdir(optFTSDir);
end
if ~exist(OTSDir, 'dir')
    mkdir(OTSDir);
end

disp('--- Ready? Go ECSSD!---')

DatasetRootPath = 'E:\PandaSpaceSyn\DataSets\SaliencyDatasets\';
srcDir = [DatasetRootPath  'ECSSD\images\images\'];

allnames=struct2cell(dir([srcDir '*.jpg']));
[~, pics_num]=size(allnames); % length


% OTSnames = struct2cell(dir([OTSDir '*.png']));
%% for test
% pics_num = 10;
%%

 tic
parfor_progress(pics_num);

parfor ind_pic = 1:pics_num
    
    imgPath = allnames{1, ind_pic};    
    srcImg = double(imread([srcDir imgPath]))./255;

    resName =  strrep(imgPath,'.jpg','.png'); % fix save name
%     flag = 0;
%     interSection = intersect(resName, [OTSnames{1,:}]', 'rows');
%     flag = isempty(interSection)
%     if ~flag
%         continue
%     end
% ind_pic
%% ==============================calculate topoMap and finalMap============%
    [fullSizePriorMap,~,spixels,OTS_fullsizeSalMap,~,frameRecord,~,~,resizeImage]= GetPriorMap(srcImg);

%     OTSPath = [OTSDir, resName]; 
%     imwrite(OTS_fullsizeSalMap, OTSPath, 'png'); % only topo,no bias

%     FTSPath = [FTSDir, resName];     % final result
%     imwrite(FTSMap, FTSPath, 'png');
%% =========================GeoRefine==================
fullSizePriorMap = NormalizeMap(fullSizePriorMap);
geoRefSal = pp_GeoRefine(img,spixels,frameRecord, fullSizePriorMap);

fusion_fullSizePriorMap = NormalizeMap(exp(geoRefSal) + exp(fullSizePriorMap));
% figure,imshow(fusion_fullSizePriorMap),title('fusion_fullSizePriorMap');

fusion_fullSizePriorMap = refineImg(fusion_fullSizePriorMap,10,1);

%% saliency optimization----------------------------------
    optFTSMap = SalMapOptDemo(srcImg,resizeImage,spixels,frameRecord,fusion_fullSizePriorMap);

    optFTSPath = [optFTSDir, resName];     % final result
    imwrite(optFTSMap, optFTSPath, 'png');

parfor_progress; 
end
parfor_progress(0);
toc

disp('ECSSD done! congratulations!')
fprintf(2,'======== THE END ========\n');