function wldDE = GetWLDFeatures(pixelList, image, spNum)

[DE Ori] = WLD(image);
%imshow(DE);figure;imshow(Ori);
[h, w, chn] = size(image);
tmpDE = reshape(DE, h*w, 1);
%tmpOri = reshape(Ori, h*w, 1);
nbins = 6;
wldDE = zeros (spNum, nbins);
%wldMean  = zeros (spNum, nbins);
%wldO  = zeros (spNum, nbins);
for n = 1 : spNum
   wldDE(n,:)   = hist(tmpDE(pixelList{n},:),nbins)/length(pixelList{n});
   %wldMean(n,:) = mean(tmpDE(pixelList{n}));
   %wldO(n,:)  = hist(tmpOri(pixelList{n},:),nbins)/length(pixelList{n});
end



