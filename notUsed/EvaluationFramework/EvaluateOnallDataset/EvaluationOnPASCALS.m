% function EvaluationOnPASCALS(FTSDir,optFTSDir,OTSDir,flatDir,FcDir)

addpath(genpath('..\'));
addpath(genpath('EdgeDetection\'));
addpath(genpath('optimization\'));

% if ~exist(FTSDir, 'dir')
%     mkdir(FTSDir);
% end
% if ~exist(optFTSDir, 'dir')
%     mkdir(optFTSDir);
% end
% if ~exist(OTSDir, 'dir')
%     mkdir(OTSDir);
% end
% 
% if ~exist(flatDir, 'dir')
%     mkdir(flatDir);
% end
% 
% if ~exist(FcDir, 'dir')
%     mkdir(FcDir);
% end

FcDir = 'E:\PandaSpaceSyn\DataSets\SaliencyDatasets\MyResult\Pascal\Feb\noBiasOTS\';

disp('--- Ready? Go PASCALS !---')

DatasetRootPath = 'E:\PandaSpaceSyn\DataSets\SaliencyDatasets\';
srcDir = [DatasetRootPath  'Pascal\salObj\datasets\imgs\pascal\'];

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
    [FTSMap,~,spixels,OTS_fullsizeSalMap,noBiasOTS,frameRecord,~,~,resizeImage,flatMap,FcMap]= GetPriorMap(srcImg);

    % OTSPath = [OTSDir, resName]; 
    % imwrite(OTS_fullsizeSalMap, OTSPath, 'png'); % only topo,no bias

    % FTSPath = [FTSDir, resName];     % final result
    % imwrite(FTSMap, FTSPath, 'png');

%     flatPath = [flatDir, resName];     % final result
%     imwrite(flatMap, flatPath, 'png');
    
%     FcPath = [FcDir, resName];     % final result
%     imwrite(FcMap, FcPath, 'png');

    noBiasPath = [FcDir, resName];     % final result
    imwrite(noBiasOTS, noBiasPath, 'png');


% %% saliency optimization----------------------------------
%     optFTSMap = SalMapOptDemo(srcImg,resizeImage,spixels,frameRecord,FTSMap);

%     optFTSPath = [optFTSDir, resName];     % final result
%     imwrite(optFTSMap, optFTSPath, 'png');

parfor_progress;
end
parfor_progress(0);
toc

disp('PASCALS done! congratulations!')
fprintf(2,'======== THE END ========\n');