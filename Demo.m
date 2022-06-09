%% =======================================================================%
% Demo for one picture to build framework for topo-saliency.
% <<Saliency Detection Inspired by Topological Perception Theory>>--(IJCV2021)
% Author: Panda
% Date:    2022.06
% Contact me: <pengpanda.uestc@gmail.com>
%=========================================================================%
clc; 
clear;
addpath('testPic\')
addpath(genpath('EdgeDetection\'));
addpath(genpath('optimization\'));

%% use multiscale?: yes =1; no =0.
useMtScale=0;  
if useMtScale
    scl = [1,0.75,0.5];
else
    scl = 1;
end

%% the filefolds for source images and saving images
 img_dir = '.\testpic\';  
 save_dir = '.\testpic\';
 
if ~exist(save_dir, 'dir')
    mkdir(save_dir);
end
 image_list = dir([img_dir '*.jpg']);
 %% computation time cost
 tic
 %% for multi-images
 for zz =1:length(image_list)
    srcimg = imread('0009.jpg');                                    % chose one image.
%     srcimg = imread([img_dir image_list(zz).name]);    % chose more image

    [sch,scw,~]=size(srcimg);
    salmap=[];
    Sots = zeros(sch,scw);
    fsal = zeros(sch,scw);

%% scales
    for i = 1:length(scl)
    
        img = imresize(srcimg, scl(i));
        
        %% ==========================================================================
        % spixels: superpixels; frameRecord: image frame; 
        [fullSizePriorMap,spixels,OTS_fullsizeSalMap,frameRecord,resizeImage]= GetPriorMap(img);
        Sts = NormalizeMap(fullSizePriorMap);

        RBDprior = getRBDPriorMap(img);  % RBD prior computing
        geoRefSal = SelectivePathway(img,spixels,frameRecord, RBDprior,OTS_fullsizeSalMap );        % local cues processing
        salmap= imresize(NormalizeMap(geoRefSal + Sts), [sch,scw]);   
        
        %%-------------------fusion-------------
        Sots = Sots + scl(i)*imresize(OTS_fullsizeSalMap, [sch,scw]);
        fsal = fsal + scl(i)*salmap;
    end
    Sots = NormalizeMap(Sots);
    fsal = NormalizeMap(fsal);
    
    %% ------------ saliency optimization----------------------------------
    Stops = imresize(SalMapOptFunc(img,resizeImage,spixels,frameRecord,fsal,20,1.2),[sch,scw]);
    
    %% save results
    imwrite(Stops, [save_dir image_list(zz).name(1:end-4) '.png'], 'png');
    
    %% show results
    figure,
    subplot(131),imshow(srcimg),title('Image');
    subplot(132),imshow(Sots),title('Sots');
    subplot(133),imshow(Stops),title('Stops');

 end
 time = toc
fprintf(2,'======== THE END ========\n');
