function fsal = GeoRefine(pixellist0, seg0, srcImg, fsal1)
numSP0 = numel(pixellist0);
[h, w, ~] = size(srcImg);

distMap = ones(h, w);
[Is, Js] = find(distMap);
distMap(:) = sqrt((Is-h/2).^2 + (Js-w/2).^2);
initSal = zeros(numSP0, 1);
dist2C = zeros(numSP0, 1);
for spi=1:numSP0
    initSal(spi) = mean(fsal1(pixellist0{spi}));
    dist2C(spi) = mean(distMap(pixellist0{spi}));
end
% 进行排序
initSal = (initSal -min(initSal)) /(max(initSal) - min(initSal));
[sortInitSal, sortIdx] = sortrows([initSal, dist2C], [1, -2]);
cumSal = cumsum(sortInitSal(:, 1))/sum(sortInitSal(:,1));
T = min(sum(cumSal<0.01), floor(numSP0/5));
%% GeoSal
bkgIdx = sortIdx(1:T);

% 背景结点可视化
bkgMask = zeros(h,w);
for spiidx = 1:T
    bkgMask(pixellist0{bkgIdx(spiidx)}) = 1;
end
% imshow(bkgMask);
% adjmatrix
adjMatrix = GetAdjMatrix(seg0, numSP0);
meanCol = GetMeanColor(srcImg, pixellist0);
meanCol = colorspace('RGB->Lab',meanCol/255);
colorD = pdist2( meanCol, meanCol, 'euclidean' );
bdrIdx = double(([seg0(:, 1:floor(h/20)); seg0(:, end-floor(h/20)+1:end); ...
    seg0(1:floor(h/20),:)'; seg0(end-floor(h/20)+1:end,:)']));
bdrIdx = unique(bdrIdx(:));
if numel(bkgIdx) == size(adjMatrix, 1)
    fsal = ones(h, w);
    return;
end
bdyLink = nchoosek(bdrIdx,2);
bdyLink = [bdyLink; bdyLink(:,2), bdyLink(:,1)];
S = full(sparse(bdyLink(:,1),bdyLink(:,2), ones(size(bdyLink,1), 1),double(numSP0),double(numSP0)));
adjMatrix = double((adjMatrix | S));
weightM = colorD.*adjMatrix;
minD = zeros(numSP0,1);
for spi=1:numSP0
    minD(spi) = min(weightM(spi, find(adjMatrix(spi,:))));
end
smallW = mean(minD);
weightM(find(weightM<smallW)) = 0;
% 增加虚拟背景结点
adjMatrix = [zeros(1, size(adjMatrix,1)+1); zeros(size(adjMatrix, 1), 1) adjMatrix];
weightM = [zeros(1, size(weightM,1)+1); zeros(size(weightM, 1), 1) weightM];

adjMatrix(1,bkgIdx+1) = 1;
adjMatrix(bkgIdx+1, 1) = 1;

geoSal = Dijstra(adjMatrix, weightM);
geoSal = geoSal(2:end);
geoSal = geoSal/(0.75*max(geoSal));
geoSal(find(geoSal>1)) = 1;
bkgSal = fsal1;


for spi=1:numSP0
    bkgSal(pixellist0{spi}) = geoSal(spi);
end
% figure
% imshow(bkgSal)

fsal = exp(fsal1).*exp(bkgSal);%or .*
fsal = (fsal-min(fsal(:)))/(max(fsal(:))-min(fsal(:))+eps);

erodeImg = imerode(fsal, strel('disk', floor(50*mean(fsal(:)))));
fsal = imreconstruct(erodeImg, fsal ); % IM = imreconstruct(MARKER, MASK) 

dilateImg = imdilate(fsal, strel('disk', floor(50*mean(fsal(:)))));
fsal = imreconstruct(dilateImg, fsal ); 
fsal = (fsal-min(fsal(:)))/(max(fsal(:))-min(fsal(:))+eps);
fsal = imfill(fsal);
end

