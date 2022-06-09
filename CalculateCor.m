function coef = CalculateCor(Smap_str, Hmap_str)
%%------------------------------------------------------------ 
% This code is compare between other methods and ground-truth
% imput: images of other results & ground-truth
% output: 
% code by Peng Peng.  2017.09.12
% contact me: peng_panda@163.com
%%----------------------------------------------------------

    Smap = double(Smap_str);
    Hmap = double(Hmap_str);

    Hmap = imresize(Hmap,size(Smap),'bilinear');

    SStd =std(Smap(:),1)*std(Hmap(:),1) ;
    temp=(Hmap-mean(Hmap(:))).*(Smap-mean(Smap(:)));
    CCoef = mean(temp(:));
    Rou = CCoef/(SStd+eps);

coef = mean(Rou); % average 
coef = coef(1);











