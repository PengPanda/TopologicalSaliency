function optSalMap = salOptimization (adjcMatrix, colDistM, neiSigma, bgWeight, fgWeight,smLambda)



adjcMatrix_nn = LinkNN(adjcMatrix);
colDistM(adjcMatrix_nn == 0) = Inf;
Wn = Dist2WeightMatrix(colDistM, neiSigma);      %smoothness term
mu = 0.1;                                                   %small coefficients for regularization term
W = Wn + adjcMatrix * mu;                                   %add regularization term
D = diag(sum(W));

   %global weight for background term, bgLambda > 1 means we rely more on bg cue than fg cue.
E_bg = diag(bgWeight);       %background term
E_fg = diag(fgWeight);          %foreground term

spNum = length(bgWeight);
optSalMap =(smLambda*D - smLambda*W + E_bg + E_fg) \ (E_fg * ones(spNum, 1));