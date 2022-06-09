function [isNest, mask_next, bNum] = FindNestArea(ucmMat, mask_i)
%myFun - Description
%
% Syntax: output = myFun(input)
%
% Long description
    sel = strel('disk',1);
    mask_ring = imdilate(mask_i,sel);
    mask_erode = imerode(mask_i, sel);
    mask_ring(mask_erode == 1) = 0;

    mask_fill = imfill(mask_i,'holes');
    mask_fill_ring = imdilate(mask_fill,sel);
    mask_fill_erode = imerode(mask_fill,sel);
    mask_fill_ring(mask_fill_erode == 1) = 0;

    idx_ard = unique(ucmMat(mask_ring==1)); % there may bath be element inner and suround  
    idx_fill_surd = unique(ucmMat(mask_fill_ring==1)); %only surround area 

    isNest = ~isequal(idx_ard, idx_fill_surd);
    
    mask_next = mask_fill - mask_i;
%     figure, imshow(mask_next,[]);
    bNum = unique(ucmMat(mask_next==1));

    
end 