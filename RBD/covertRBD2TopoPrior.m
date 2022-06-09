function [topoBgProb,bgWeight] = covertRBD2TopoPrior(noFrameImg,pixelList,colDistM, adjcMatrix, bdIds, clipVal, geoSigma)

[~, ~, ~,OTS_fullsizeSalMap,~,~,~,~,~,~,~] = GetPriorMap(noFrameImg);
% 
% figure
% imshow(OTS_fullsizeSalMap,[])
% spNumb = unique(idxImg);
% [h,w,~] = size(srcImg);
% topoBgProb = zeros(h,w);

for inum = numel(pixelList)
    allpixels = [];
    allpixels = OTS_fullsizeSalMap(pixelList{inum});
    tempTopoBgProb(inum) = mean(allpixels(:));
end
topoBgProb = 1- tempTopoBgProb';



bdCon = BoundaryConnectivity(adjcMatrix, colDistM, bdIds, clipVal, geoSigma, true);

bdConSigma = 1; %sigma for converting bdCon value to background probability
% fgProb = exp(-bdCon.^2 / (2 * bdConSigma * bdConSigma)); %Estimate bg probability
% bgProb = 1 - fgProb;

bgWeight = topoBgProb;
% Give a very large weight for very confident bg sps can get slightly
% better saliency maps, you can turn it off.
fixHighBdConSP = true;
highThresh = 3;
if fixHighBdConSP
    bgWeight(bdCon > highThresh) = 1000;
end


