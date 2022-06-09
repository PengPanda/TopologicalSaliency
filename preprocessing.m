function [Sots, S_nb, frameRecord] = preprocessing(Image)
%% do some preprocessings for Sots. like removing regions touching borders.
% input and outputs are the same as function <getTopoComplexityMap.m> 
%%

resizeImage = Image;
%%  ----------preprocessing-----------
[ww,hh,~] = size(resizeImage);
[colorsalMap, DisMap] = getcolormap(resizeImage);
%%----------
level = 0.8*graythresh(colorsalMap); 
I = im2bw(colorsalMap,level);
%%-----------

wd = 5;
for x = wd:ww-wd
    for y = wd: hh-wd
        I(x,y) = 0;      
    end
end

B = repmat(double(I),[1,1,3]);
%% - some regions touching borders, we removed them------------
if sum(sum(sum(B==1)))>0
    A =255- uint8(double(resizeImage).*B);
    resizeImage(B==1) = A(B==1);
%     figure
%     imshow(srcImg)
end
%% ------
[Sots, S_nb,frameRecord] = getTopoComplexityMap(resizeImage);
% figure
% imshow(Sots)
