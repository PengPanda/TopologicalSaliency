function [S_nb,U] =  getUCM(I)
% code by pp
addpath(genpath('EdgeDetection'));
% addpath(genpath('toolbox\channels\private\'));
%% load pre-trained edge detection model and set opts (see edgesDemo.m)
model=load('EdgeDetection\models\forest\modelBsds'); model=model.model;
model.opts.nms=-1; model.opts.nThreads=4;
model.opts.multiscale=0; model.opts.sharpen=2;

%% set up opts for spDetect (see spDetect.m)
opts = spDetect;
opts.nThreads = 4;  % number of computation threads
opts.k = 1024;       % controls scale of superpixels (big k -> big sp) 25£¬£¬400
opts.alpha = .5;    % relative importance of regularity versus data terms
opts.beta = .9;     % relative importance of edge versus color terms
opts.merge = 0;     % set to small value to merge nearby superpixels at end
opts.bounds = 1;
%% detect and display superpixels (see spDetect.m)
% I = imread('21093.jpg');
[E,~,~,segs]=edgesDetect(I,model);
[S,V] = spDetect(I,E,opts);


%% compute ultrametric contour map from superpixels (see spAffinities.m)
[~,~,U]=spAffinities(S,E,segs,opts.nThreads);
% figure(3); im(1-U); return;
%%
opts.bounds = 0;
[S_nb,~] = spDetect(I,E,opts);
% figure(1); im(I); 
% figure(2); im(V);figure(3); im(S_nb);