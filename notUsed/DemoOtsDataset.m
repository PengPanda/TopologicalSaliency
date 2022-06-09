% Demo to build framework for toposaliency
%
%
% peng PENG <pengpanda.uestc@gmail.com>
% October
%=========================================================================%
clc; 
clear all;
close all;
addpath('testPic\')
% addpath('..\ECSSD\')
addpath(genpath('RBD\'));
addpath(genpath('RBD\Funs\'));
addpath(genpath('GeoFunc\'));
addpath(genpath('EdgeDetection\'));
addpath(genpath('optimization\'));

useMtScale=0;
if useMtScale
    scl = [1,0.75,0.5];
else
    scl = 1;
end

 img_dir = 'E:\PandaSpaceSyn\DataSets\SaliencyDatasets\HKU-IS\imgs\';
 save_dir = '.\results\preHKUIS-ots\';
%  
if ~exist(save_dir, 'dir')
    mkdir(save_dir);
end
 image_list = dir([img_dir '*.png']);
 
 done_structure = dir([save_dir '*.png']);%% done list
 done_list = {};
 for dd =1:length(done_structure)
    done_list{dd} = done_structure(dd).name(1:end-4);
 end
 
 
 tic
 parfor_progress(length(image_list));
parfor zz =1:length(image_list)

% srcimg = imread('1_45_45784.jpg');
    imgname = image_list(zz).name;
    if ismember(imgname(1:end-4), done_list) 
        parfor_progress;
        continue
    end
 srcimg = imread([img_dir imgname]);

% figure,imshow(srcimg,[]),title('img');
[sch,scw,~]=size(srcimg);
salmap=[];
Sots = zeros(sch,scw);
fsal = zeros(sch,scw);

for i = 1:length(scl)
   
    img = imresize(srcimg, scl(i));
    
    %% ==========================================================================
    [fullSizePriorMap,spixels,OTS_fullsizeSalMap,frameRecord,resizeImage]= GetPriorMap(img);

end
    Sots = NormalizeMap(OTS_fullsizeSalMap);
%     figure
%     imshow(Sots)

    imwrite(Sots, [save_dir image_list(zz).name(1:end-4) '.png'], 'png');

parfor_progress;
 end
 parfor_progress(0);
 time = toc/length(image_list)
fprintf(2,'======== THE END ========\n');
