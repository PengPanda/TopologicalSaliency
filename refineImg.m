function refImg = refineImg(unRefImg,lambda,beta)
%% refine img for 1-channel img

% lambda = 20;
% beta=0.9;
lambda = lambda;
beta=beta;

level=graythresh(unRefImg); 

FlattenedData = unRefImg(:)'; % normalize
FlattenedData = 1./(1 + exp((beta*level - FlattenedData)*lambda));%%% optional
MappedFlattened = mapminmax(FlattenedData, 0, 1); % you can try some other params there
refImg = reshape(MappedFlattened, size(unRefImg)); 