clear ;
close all
clc

addpath(genpath('E:\PandaSpaceSyn\DataSets\SaliencyDatasets\'));
addpath('E:\PandaSpaceSyn\DataSets\otherData\ASD\HC\');% HC path
addpath('E:\PandaSpaceSyn\DataSets\otherData\ASD\RC\'); % RC path
rootpath = 'E:\PandaSpaceSyn\DataSets\SaliencyDatasets\';
addpath(genpath('..\'));
addpath(genpath('.\EdgeDetection\'));


srcDir= [rootpath  'ASD\Img1000\'];  %Choose source directory
% srcDir=uigetdir('Choose source directory.');  %Choose source directory
allnames=struct2cell(dir([srcDir '*.jpg'])); % get name strings


FusionResultDir = [rootpath 'MyResult\TopoFrameworkOnASD\'];



[~, pics_num]=size(allnames); % length
% pics_num = 10;
tic
parfor_progress(pics_num);
parfor ind_pic = 1:pics_num

    imgPath = allnames{1, ind_pic};   
    
    imgNum =  imgPath;
    imgNum(end-3:end) = [];

%     imgNum = '468';
    postName1 = '_HC';
    postName2 = '_RC';
    fileString = '.jpg'; % 
    salFileString = '.png';

    imgName = [srcDir imgNum fileString];
    salName1 = [imgNum postName1 salFileString];
    salName2 = [imgNum postName2 salFileString];

    srcImg = double(imread(imgName))./255;
    ColorMap1 = double(imread(salName1))./255;
    ColorMap2 = double(imread(salName2))./255;
    ColorMap2 = 0.001*ones(size(ColorMap2))+ColorMap2;
    
% figure,imshow(srcImg);

    % srcImg = double(imread([srcDir imgPath]))./255;
    resName =  strrep(imgPath,'.jpg','.png'); % fix save name
    
%%==============================calculate topoMap and finalMap============%

    % [fullSizepriorMap,priorMap,spixels,fusion_SaliencyMap,noBaisMap,frameRecord]= GetPriorMap(srcImg);
    [fullSizePriorMap,priorMap,spixels,fusion_SaliencyMap,noBaisMap,frameRecord]= GetPriorMapFramework(srcImg,ColorMap1,ColorMap2);
    
    % tpSalPath = fullfile(TopoResultDir, resName);     
    % imwrite(fusion_SaliencyMap, tpSalPath, 'png'); % only topo
    
    
    SalPath = fullfile(FusionResultDir, resName);     % final result
    imwrite(fullSizePriorMap, SalPath, 'png');
%     figure,imshow(fullSizePriorMap);
%%================================calculate BayesMap======================%


%     SOmap = CGVSsalient(map,Iter);
% %     figure;imshow(SOmap,[]);
%     repath = fullfile(BayesResultsDir,resName);     
%     imwrite(SOmap,repath,'png');
%%-------------------------------------------------------------------------   
     parfor_progress 
end
parfor_progress(0);
toc
disp('done! congratulations!')
fprintf(2,'======== THE END ========\n');
%=========================================================================%
