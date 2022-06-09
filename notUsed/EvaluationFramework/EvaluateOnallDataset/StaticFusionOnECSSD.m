% function EvaluationOnPASCALS_OTS(FTSDir,optFTSDir,OTSDir)

addpath(genpath('..\'));
addpath(genpath('EdgeDetection\'));
addpath(genpath('optimization\'));
addpath(genpath('GeoFunc\'));

optFTSDir = 'E:\PandaSpaceSyn\GeoRefineResult\parameterAnalysis\lambda\onlySge_OnDUTO\';
% optFTSDir = 'E:\PandaSpaceSyn\GeoRefineResult\parameterAnalysis\lambda\singleScale_OnDUTO\';
% if ~exist(FTSDir, 'dir')
%     mkdir(FTSDir);
% end
if ~exist(optFTSDir, 'dir')
    mkdir(optFTSDir);
end
% if ~exist(OTSDir, 'dir')
%     mkdir(OTSDir);
% end
%% 
%{
optFTSDir1 = 'E:\PandaSpaceSyn\GeoRefineResult\parameterAnalysis\lambda\20_1.1_OnECSSD\';
% if ~exist(FTSDir, 'dir')
%     mkdir(FTSDir);
% end
if ~exist(optFTSDir1, 'dir')
    mkdir(optFTSDir1);
end

optFTSDir2 = 'E:\PandaSpaceSyn\GeoRefineResult\parameterAnalysis\lambda\20_1.3_OnECSSD\';
% if ~exist(FTSDir, 'dir')
%     mkdir(FTSDir);
% end
if ~exist(optFTSDir2, 'dir')
    mkdir(optFTSDir2);
end

optFTSDir3 = 'E:\PandaSpaceSyn\GeoRefineResult\parameterAnalysis\lambda\10_1.2_OnECSSD\';
% if ~exist(FTSDir, 'dir')
%     mkdir(FTSDir);
% end
if ~exist(optFTSDir3, 'dir')
    mkdir(optFTSDir3);
end

optFTSDir4 = 'E:\PandaSpaceSyn\GeoRefineResult\parameterAnalysis\lambda\30_1.2_OnECSSD\';
% if ~exist(FTSDir, 'dir')
%     mkdir(FTSDir);
% end
if ~exist(optFTSDir4, 'dir')
    mkdir(optFTSDir4);
end
%}
%%

disp('--- Ready? Go ECSSD!---')

DatasetRootPath = 'E:\PandaSpaceSyn\DataSets\SaliencyDatasets\';
% srcDir = [DatasetRootPath  'Pascal\salObj\datasets\imgs\pascal\'];
% srcDir = [DatasetRootPath  'ECSSD\images\images\'];
srcDir = [DatasetRootPath  'DUT-OMRON\DUT-OMRON-image\'];

allnames=struct2cell(dir([srcDir '*.jpg']));
[~, pics_num]=size(allnames); % length


allDoneImageName = struct2cell(dir([optFTSDir '*.png']));
% [~, done_pics_num]=size(done_names); % length
[~, numDoneImg]=size(allDoneImageName); % length

allDoneList={};
for inum = 1:numDoneImg
    allDoneList{inum} =allDoneImageName{1, inum};
end


%% for test
% pics_num = 5;
%%
scl = [1,0.75,0.5];
% scl=[1];

 tic
parfor_progress(pics_num);
corList = [];

parfor ind_pic = 1:pics_num
    %%
 

    topoPrior = [];
    topSalMap=[];
    topOptSalMap=[];
    geoSalMap=[];
    geoOptSalMap=[];
      
    %%
    
    imgPath = allnames{1, ind_pic};    
    simg = imread([srcDir imgPath]);
    %%
    [sch,scw,d]=size(simg);    
    resName =  strrep(imgPath,'.jpg','.png'); % fix save name
    
%     if ~isempty(allDoneList) && ismember(resName, allDoneList)
%         parfor_progress;
%         continue
%     end
    
    if d==1
        srcimg = repmat(simg,[1,1,3]);
    else
        srcimg=simg;
    end
%%
for i = 1:length(scl)
     sci=scl(i);
    img = imresize(srcimg,sci);
    [~, ~,RBDprior] = getOtherPriorMap(img);

   
%% ==========================================================================
   [fullSizePriorMap,priorMap,spixels,OTS_fullsizeSalMap,noBaisMap,frameRecord,~,~,resizeImage,~,~,~,cor]= GetPriorMap(img);
%     
%figure,imshow(OTS_fullsizeSalMap),title('TOPO');
%    OTSPath = [optFTSDir, resName];     % ots result
%     imwrite(OTS_fullsizeSalMap, OTSPath, 'png');  
%     corList = [corList, cor];
    

    topoPrior(:,:,i)=imresize(OTS_fullsizeSalMap,[sch,scw]);
    %=============GeoRefine============================================================%



    fullSizePriorMap = NormalizeMap(refineImg(fullSizePriorMap,10,1));
%     figure,imshow(fullSizePriorMap),title('FusionMap');
    topSalMap(:,:,i) = imresize(fullSizePriorMap,[sch,scw]);
 
    
%% ==  only Sge
    OTS_fullsizeSalMap = zeros(size(RBDprior));
    fullSizePriorMap = zeros(size(OTS_fullsizeSalMap));
    
%% ==
    priormap = refineImg(NormalizeMap(RBDprior+OTS_fullsizeSalMap),10,0.9);
    geoRefSal = pp_GeoRefine(img,spixels,frameRecord, priormap);

    fusion_fullSizePriorMap = NormalizeMap(geoRefSal + fullSizePriorMap);
%     figure,imshow(fusion_fullSizePriorMap),title('fusion_fullSizePriorMap');

%     fusion_fullSizePriorMap = refineImg(fusion_fullSizePriorMap,10,1);
    geoSalMap(:,:,i) = imresize(fusion_fullSizePriorMap,[sch,scw]);
    % fusion_fullSizePriorMap =fullSizePriorMap;
%     %%------------ saliency optimization----------------------------------
%     fullSizeOptSalMap = SalMapOptDemo(img,resizeImage,spixels,frameRecord,fullSizePriorMap,20,.9);
% %     figure,imshow(fullSizeOptSalMap),title('OptSalMap');
    topOptSalMap(:,:,i) = imresize(fullSizePriorMap,[sch,scw]);
% 
%     fullSizeOptSalMap = SalMapOptDemo(img,resizeImage,spixels,frameRecord,fusion_fullSizePriorMap,20,1.2);
% %     figure,imshow(fullSizeOptSalMap),title('geoOptSalMap');
    geoOptSalMap(:,:,i) = imresize(fusion_fullSizePriorMap,[sch,scw]);
    
end

%     fsal1 = NormalizeMap(topoPrior(:,:,1)+topoPrior(:,:,2)+topoPrior(:,:,3));
%     fsal2 = NormalizeMap(topSalMap(:,:,1)+topSalMap(:,:,2)+topSalMap(:,:,3));
%     fsal3 = NormalizeMap(geoSalMap(:,:,1)+geoSalMap(:,:,2)+geoSalMap(:,:,3));
    fsal5 = NormalizeMap(topOptSalMap(:,:,1)+0.75*topOptSalMap(:,:,2)+0.5*topOptSalMap(:,:,3));
%     fsal5 = NormalizeMap(geoOptSalMap(:,:,1)+1*geoOptSalMap(:,:,2)+1*geoOptSalMap(:,:,3));
% fsal5 = NormalizeMap(geoOptSalMap(:,:,1));

    %%------------ saliency optimization----------------------------------
%     fullSizeOptSalMap = SalMapOptDemo(img,resizeImage,spixels,frameRecord,fsal4,20,.9);
% %     figure,imshow(fullSizeOptSalMap),title('OptSalMap');
%     fsal4 = imresize(fullSizeOptSalMap,[sch,scw]);

%% ---20, 1.2
    fullSizeOptSalMap = SalMapOptDemo(img,resizeImage,spixels,frameRecord,fsal5,20,1.2);
%     figure,imshow(fullSizeOptSalMap),title('geoOptSalMap');
    fsal5 = imresize(fullSizeOptSalMap,[sch,scw]);

    optFTSPath = [optFTSDir, resName];     % final result
    imwrite(fsal5, optFTSPath, 'png');  

%{
%% ---20,1.1
    fullSizeOptSalMap = SalMapOptDemo(img,resizeImage,spixels,frameRecord,fsal5,20,1.1);
%     figure,imshow(fullSizeOptSalMap),title('geoOptSalMap');
    fsal5 = imresize(fullSizeOptSalMap,[sch,scw]);

    optFTSPath = [optFTSDir1, resName];     % final result
    imwrite(fsal5, optFTSPath, 'png');  

%% ---20.1.3
    fullSizeOptSalMap = SalMapOptDemo(img,resizeImage,spixels,frameRecord,fsal5,20,1.3);
%     figure,imshow(fullSizeOptSalMap),title('geoOptSalMap');
    fsal5 = imresize(fullSizeOptSalMap,[sch,scw]);

    optFTSPath = [optFTSDir2, resName];     % final result
    imwrite(fsal5, optFTSPath, 'png');  


%% ---10,1.2
    fullSizeOptSalMap = SalMapOptDemo(img,resizeImage,spixels,frameRecord,fsal5,10,1.2);
%     figure,imshow(fullSizeOptSalMap),title('geoOptSalMap');
    fsal5 = imresize(fullSizeOptSalMap,[sch,scw]);

    optFTSPath = [optFTSDir3, resName];     % final result
    imwrite(fsal5, optFTSPath, 'png');  

%% --30, 1.2
    fullSizeOptSalMap = SalMapOptDemo(img,resizeImage,spixels,frameRecord,fsal5,30,1.2);
%     figure,imshow(fullSizeOptSalMap),title('geoOptSalMap');
    fsal5 = imresize(fullSizeOptSalMap,[sch,scw]);

    optFTSPath = [optFTSDir4, resName];     % final result
    imwrite(fsal5, optFTSPath, 'png');  
%}
parfor_progress; 
end
parfor_progress(0);
toc
% save('corList_onECSSD.mat', corList);

disp('ECSSD done! congratulations!')
fprintf(2,'======== THE END ========\n');