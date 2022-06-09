function EvaluationOnASD(FTSDir,optFTSDir,OTSDir)

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

disp('--- Ready? Go ASD!---')

DatasetRootPath = 'E:\PandaSpaceSyn\DataSets\SaliencyDatasets\';
srcDir = [DatasetRootPath  'ASD\Img1000\'];

allnames=struct2cell(dir([srcDir '*.jpg']));
[~, pics_num]=size(allnames); % length
%% for test
% pics_num = 10;
%%

 tic
parfor_progress(pics_num);
parfor ind_pic = 1:pics_num
    
    imgPath = allnames{1, ind_pic};    
    srcImg = double(imread([srcDir imgPath]))./255;

    resName =  strrep(imgPath,'.jpg','.png'); % fix save name

%%==============================calculate topoMap and finalMap============%
    [FTSMap,~,spixels,OTS_fullsizeSalMap,~,frameRecord,~,~,resizeImage]= GetPriorMap(srcImg);

    OTSPath = [OTSDir, resName]; 
    imwrite(OTS_fullsizeSalMap, OTSPath, 'png'); % only topo,no bias

    FTSPath = [FTSDir, resName];     % final result
    imwrite(FTSMap, FTSPath, 'png');



%% saliency optimization----------------------------------
    optFTSMap = SalMapOptDemo(srcImg,resizeImage,spixels,frameRecord,FTSMap);

    optFTSPath = [optFTSDir, resName];     % final result
    imwrite(optFTSMap, optFTSPath, 'png');

parfor_progress;
end
parfor_progress(0);
toc

disp('ASD done! congratulations!')
fprintf(2,'======== THE END ========\n');