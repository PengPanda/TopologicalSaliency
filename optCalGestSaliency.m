function [ColorDistSalMap,ColorSalMap,ColMapWithoutTopo] = optCalGestSaliency(I, S, sigma, Sots,frameRecord)
%
%
%
%% ======================remove frame=================================
Img= I(frameRecord(3):frameRecord(4), frameRecord(5):frameRecord(6),:);

LabImage = rgb2lab(Img);
[ww, hh,~]=size(I);
ColorDistSalMap = zeros(ww, hh);
ColorSalMap = zeros(ww, hh);
ColMapWithoutTopo = ColorSalMap;
%%==========================================================
Seg = S; %superpixels
   
DisMap = zeros(size(Seg));
% RestrMap = zeros(size(Seg));
ColorMap = zeros(size(Seg));

% DisMapWithoutTopo = ColorMap;
% ClusterMap = zeros(size(Seg));
% Clu_WeightMap = zeros(size(Seg));
% Topo_prior_Map = zeros(size(Seg)); % topo prior map
% bg_prior_Map= Topo_prior_Map;


sigma = 2*sigma^2;
% alpha = 1;

sq_seg = unique(Seg(:));
len_Seg = length(sq_seg);

seq_bg = [];
seq_x = [];
seq_y = [];
seq_l = [];
seq_a = [];
seq_b = [];

% topo noBaisMap
bg_prior_Map = 1 - Sots;

L = LabImage(:,:,1);
A = LabImage(:,:,2);
B = LabImage(:,:,3);

for num = 1:len_Seg
    [x, y] = find(Seg == sq_seg(num));
    seq_x = [seq_x, mean(x)];
    seq_y = [seq_y, mean(y)];

    idx = find(Seg == sq_seg(num));
    l = L(idx);
    a = A(idx);
    b = B(idx);
    
    Topo = bg_prior_Map(idx);
    seq_bg = [seq_bg, mean(Topo)]; % topo prior
    
    seq_l = [seq_l, mean(l)];
    seq_a = [seq_a, mean(a)];
    seq_b = [seq_b, mean(b)];
end

cdMatrix = [seq_x; seq_y]; %
len1 = length(cdMatrix(1,:));
clMatrix = [seq_l; seq_a; seq_b]; % color matrix
len2 = length(clMatrix(1,:));

Dist = [];
DisC = [];
% DisColMap = [];
% pureDis = [];

for i = 1:len_Seg
    x0 = seq_x(i);
    y0 = seq_y(i);
    l0 = seq_l(i);
    a0 = seq_a(i);
    b0 = seq_b(i);

    tempCdMatrix = repmat([x0; y0], [1, len1]);
    tempClMatrix = repmat([l0; a0; b0], [1, len2]);

    resCdMatrix = (cdMatrix-tempCdMatrix).^2;
    resClMatrix = (clMatrix-tempClMatrix).^2;
    
%     Dist_test(i) = sum(exp(-sum(resCdMatrix)./sigma))/len_Seg;
    DisC(i) = sum(sqrt(sum(resClMatrix)))/len_Seg;  %% Sc in paper
    
    Dist(i) = sum(exp(-sum(resCdMatrix)./sigma).*seq_bg.*sqrt(sum(resClMatrix)))/len_Seg;  %Sd
    
end

%%
for i = 1:len_Seg
    DisMap(Seg == sq_seg(i)) = Dist(i); %Sd
    ColorMap(Seg == sq_seg(i)) = DisC(i); %Sc
%     DisMapWithoutTopo(Seg == sq_seg(i)) = DisColMap(i);
end

ColorDistSalMap(frameRecord(3):frameRecord(4), frameRecord(5):frameRecord(6)) = DisMap;
ColorSalMap(frameRecord(3):frameRecord(4), frameRecord(5):frameRecord(6)) = ColorMap;
% ColMapWithoutTopo(frameRecord(3):frameRecord(4), frameRecord(5):frameRecord(6)) = DisMapWithoutTopo;

