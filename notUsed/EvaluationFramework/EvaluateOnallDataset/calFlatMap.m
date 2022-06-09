function calFlatFcMap()
% on pascal


rootDir = 'E:\PandaSpaceSyn\DataSets\SaliencyDatasets\MyResult\';
strFlat = 'flatMap\';
strFc = 'FcMap\';

strFTS = 'Feb\FebFTS\';
strOptFTS = 'Feb\FebOptFTS\';
strOTS = 'Feb\FebOTS\';

strPASCALS = 'Pascal\';


FTSDir = [rootDir  strPASCALS  strFTS];
optFTSDir = [rootDir  strPASCALS  strOptFTS]; 
OTSDir =  [rootDir  strPASCALS  strOTS];

flatDir = [rootDir  strPASCALS  strFlat];
FcDir = [rootDir  strPASCALS  strFc];
EvaluationOnPASCALS(FTSDir,optFTSDir,OTSDir,flatDir,FcDir);
