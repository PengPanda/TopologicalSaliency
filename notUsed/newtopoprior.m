close all
clear all
addpath('E:\PandaSpaceSyn\GeoRefineResult\SOD (20200303)\testPic');
addpath('./test/');
srcImg= imread('49481.jpg');

[ww,hh,nchns] = size(srcImg);
if nchns == 1
    srcImg(:, :, 2) = srcImg(:, :, 1);
    srcImg(:, :, 3) = srcImg(:, :, 1);
end

if ww>hh
    srcImg = imresize(srcImg,[400 floor(hh*(400/ww))],'bilinear');
elseif ww<=hh
    srcImg = imresize(srcImg,[floor(ww*(400/hh)) 400],'bilinear');
end
resizeImage = srcImg;


%%  ----------preprocessing-----------
[ww,hh,nchns] = size(resizeImage);
[colorsalMap, DisMap] = getcolormap(resizeImage);
figure
imshow(colorsalMap)
title('colormap')

figure
imshow(DisMap)
title('DisMap')
%%----------
level = 0.8*graythresh(colorsalMap); 
I = im2bw(colorsalMap,level);
figure
imshow(I)
%%-----------

wd = 5;
for x = wd:ww-wd
    for y = wd: hh-wd
        I(x,y) = 0;      
    end
end
figure
imshow(I)
B = repmat(double(I),[1,1,3]);
figure
imshow(B)
%%-------------
if sum(B==1)
    A =255- uint8(double(srcImg).*B);
    srcImg(B==1) = A(B==1);
    figure
    imshow(srcImg)
else
    srcImg = resizeImage;
end
%%------
[Sots, S_nb,frameRecord] = ppSoftSalDetect(srcImg);
figure
imshow(Sots)
