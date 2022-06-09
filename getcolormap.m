function [ColorSalMap, ColorDistSalMap] = getcolormap(image)
%% use topo-complexity map(OTS map) to calculate center-surround contrasts.
% input: original image
% output£º  ColorSalMap: topo-prior guided color contrast; 
%                 ColorDistSalMap: topo-prior guided color contrast with distance;
% 
%%
% get topo-prior

[Sots, S,frameRecord] = getTopoComplexityMap(image);
sigma = 100;
%% ======================remove frame=================================
Img = image(frameRecord(3):frameRecord(4), frameRecord(5):frameRecord(6),:);
LabImage = rgb2lab(Img);
[ww, hh,~]=size(Img);
ColorDistSalMap = zeros(ww, hh);
ColorSalMap = zeros(ww, hh);
ColMapWithoutTopo = ColorSalMap;
%%==========================================================
Seg = S; %superpixels
   
DisMap = zeros(size(Seg));
% RestrMap = zeros(size(Seg));
ColorMap = zeros(size(Seg));

sigma = 2*sigma^2;
alpha = 1;

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


for num = 1:len_Seg
    [x, y] = find(Seg == sq_seg(num));
    seq_x = [seq_x; mean(x)];
    seq_y = [seq_y; mean(y)];

    L = LabImage(:,:,1);
    A = LabImage(:,:,2);
    B = LabImage(:,:,3);
    
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


Dist = [];
DisC = [];
DisColMap = [];

for i = 1:len_Seg
    x0 = seq_x(i);
    y0 = seq_y(i);
    l0 = seq_l(i);
    a0 = seq_a(i);
    b0 = seq_b(i);
    D = 0;
    DisCi = 0;
    DisCol = 0;

    for j = 1:len_Seg
        x = seq_x(j);
        y = seq_y(j);
        l = seq_l(j);
        a = seq_a(j);
        b = seq_b(j);

        wTopo=seq_bg(j); %
        
        
        Dis = exp(-((x-x0).*(x-x0) + (y-y0).*(y-y0))/sigma);
        DisColorList = sqrt((l-l0).*(l-l0) + (a-a0).*(a-a0) + (b-b0).*(b-b0)); % color distance
        DisCo = DisColorList;
        D = D + alpha*Dis*DisCo;
        DisCi= DisCi + DisCo;

    end
    Dist = [Dist; D/len_Seg];
    DisC = [DisC; DisCi];
end
%%
for i = 1:len_Seg
    DisMap(Seg == sq_seg(i)) = Dist(i); 
    ColorMap(Seg == sq_seg(i)) = DisC(i);
end

DisMap = NormalizeMap(DisMap);
ColorMap = NormalizeMap(ColorMap);

% restore image frame (for some images);
ColorDistSalMap(frameRecord(3):frameRecord(4), frameRecord(5):frameRecord(6)) = DisMap;
ColorSalMap(frameRecord(3):frameRecord(4), frameRecord(5):frameRecord(6)) = ColorMap;


