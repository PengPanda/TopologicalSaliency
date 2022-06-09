function adjcMatrix = LinkNN(adjcMatrix)
%link 2 layers of neighbor super-pixels 


adjcMatrix = (adjcMatrix * adjcMatrix + adjcMatrix) > 0;
adjcMatrix = double(adjcMatrix);

% adjcMatrix(bdIds, bdIds) = 1;