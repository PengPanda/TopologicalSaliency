% Demo to build framework for toposaliency
%
%
% peng PENG <pengpanda.uestc@gmail.com>
% October
%=========================================================================%
clc;
clear;
close all;
addpath('testPic\')

addpath(genpath('RBD\'));
addpath(genpath('RBD\Funs\'));
addpath(genpath('GeoFunc\'));
addpath(genpath('EdgeDetection\'));
addpath(genpath('optimization\'));

useMtScale = 1;

if useMtScale
    scl = [1, 0.75, 0.5];
else
    scl = 1;
end

img_dir = '.\testpic\ECSSD\';
save_dir = '.\results\ParamSens\ECSSD_sigma50\';

if ~exist(save_dir, 'dir')
    mkdir(save_dir);
end

image_list = dir([img_dir '*.jpg']);

tic
parfor_progress(length(image_list));

parfor zz = 1:length(image_list)

    % srcimg = imread('1_45_45784.jpg');
    srcimg = imread([img_dir image_list(zz).name]);

    % figure,imshow(srcimg,[]),title('img');
    [sch, scw, ~] = size(srcimg);
    salmap = [];
    Sots = zeros(sch, scw);
    fsal = zeros(sch, scw);

    for i = 1:length(scl)

        img = imresize(srcimg, scl(i));

        %% ==========================================================================
        [fullSizePriorMap, spixels, OTS_fullsizeSalMap, frameRecord, resizeImage] = GetPriorMap(img);
        %     figure,imshow(OTS_fullsizeSalMap),title('OTS');
        Sps = NormalizeMap(fullSizePriorMap);

        RBDprior = getRBDPriorMap(img);

        priormap = refineImg(NormalizeMap(RBDprior + OTS_fullsizeSalMap), 10, 0.9);
        %     priormap = NormalizeMap(RBDprior+OTS_fullsizeSalMap);
        Srs = pp_GeoRefine(img, spixels, frameRecord, priormap);

        salmap = imresize(NormalizeMap(Srs + Sps), [sch, scw]);
        %      salmap= imresize(NormalizeMap(geoRefSal), [sch,scw]);   %woSts
        %%-------------------fusion-------------
        %     Sots = Sots + scl(i)*imresize(OTS_fullsizeSalMap, [sch,scw]);
        fsal = fsal + scl(i) * salmap;
    end

    %     Sots = NormalizeMap(Sots);
    fsal = NormalizeMap(fsal);
    %%------------ saliency optimization----------------------------------
    Stops = imresize(SalMapOptDemo(img, resizeImage, spixels, frameRecord, fsal, 20, 1.2), [sch, scw]);

    imwrite(Stops, [save_dir image_list(zz).name(1:end - 4) '.png'], 'png');

    %     figure,
    %     subplot(131),imshow(srcimg),title('Image');
    %     subplot(132),imshow(Sots),title('Sots');
    %     subplot(133),imshow(Stops),title('Stops');
    parfor_progress;
end

parfor_progress(0);
time = toc / length(image_list)
fprintf(2, '======== THE END ========\n');
