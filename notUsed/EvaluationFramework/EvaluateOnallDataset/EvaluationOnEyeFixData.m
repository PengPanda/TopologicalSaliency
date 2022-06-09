% function EvaluationOnPASCALS(FTSDir,optFTSDir,OTSDir,flatDir,FcDir)

addpath(genpath('..\'));
addpath(genpath('EdgeDetection\'));
addpath(genpath('optimization\'));

disp('--- Ready? Go!---')

% DatasetRootPath = 'E:\PandaSpaceSyn\DataSets\SaliencyDatasets\';
srcDir = 'E:\PandaSpaceSyn\DataSets\SaliencyDatasets\SALICON\images\test\';
reJuddDir = 'E:\PandaSpaceSyn\DataSets\SaliencyDatasets\MyResult\SALICON\test\OTS\OTS\';
reTCDir = 'E:\PandaSpaceSyn\DataSets\SaliencyDatasets\MyResult\SALICON\test\TC\TC\';

allnames=struct2cell(dir([srcDir '*.jpg'])); %imgsal: .bmp, MIT:jpeg
[~, pics_num]=size(allnames); % length
%% for test
% pics_num = 10;
%%

tic
parfor_progress(pics_num);
parfor ind_pic = 1:pics_num
    
    imgPath = allnames{1, ind_pic};    
%     srcImg = double(imread([srcDir imgPath]))./255;
    srcImg = imread([srcDir imgPath]);

    resName =  strrep(imgPath,'.jpg','.png'); % fix save name

%%==============================calculate topoMap and finalMap============%
    [FTSMap,~,spixels,OTS_fullsizeSalMap,noBaisStc,frameRecord,~,~,resizeImage,flatMap,FcMap,Stc]= GetPriorMap(srcImg);


%     flatPath = [flatDir, resName];     % final result
%     imwrite(flatMap, flatPath, 'png');
    
    reJuddPath = [reJuddDir, resName];     % final result
    imwrite(OTS_fullsizeSalMap, reJuddPath, 'png');
    
    reTCPath = [reTCDir, resName];     % final result
    imwrite(Stc, reTCPath, 'png');


% %% saliency optimization----------------------------------
%     optFTSMap = SalMapOptDemo(srcImg,resizeImage,spixels,frameRecord,FTSMap);

%     optFTSPath = [optFTSDir, resName];     % final result
%     imwrite(optFTSMap, optFTSPath, 'png');

parfor_progress;
end
parfor_progress(0);
toc

disp('Done! congratulations!')
fprintf(2,'======== THE END ========\n');