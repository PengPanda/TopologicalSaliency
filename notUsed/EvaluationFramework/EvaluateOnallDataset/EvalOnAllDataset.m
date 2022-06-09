
%% Evaluation on all datasets.
% code by pengpeng
%%

rootDir = 'E:\PandaSpaceSyn\DataSets\SaliencyDatasets\MyResult\';
strFTS = 'Feb\FebFTS\';
strOptFTS = 'Feb\FebOptFTS\';
strOTS = 'Feb\FebOTS\';

% %% on ASD/FT ======================================
% strASD = 'ASD20191129\';
% FTSDir = [rootDir strASD strFTS];
% optFTSDir = [rootDir  strASD  strOptFTS];
% OTSDir =  [rootDir  strASD  strOTS];
% 
% EvaluationOnASD(FTSDir,optFTSDir,OTSDir);
% 
% FTSDir = [];
% optFTSDir = [];
% OTSDir =  [];
% %% on ECSSD ======================================
% strECSSD = 'ECSSD\';
% FTSDir = [rootDir strECSSD strFTS];
% optFTSDir = [rootDir  strECSSD  strOptFTS];
% OTSDir =  [rootDir  strECSSD  strOTS];
% 
% EvaluationOnECSSD(FTSDir,optFTSDir,OTSDir);
% 
% FTSDir = [];
% optFTSDir = [];
% OTSDir =  [];
% % 
% % 
% % %% on PASCALS ======================================
% strPASCALS = 'Pascal\';
% FTSDir = [rootDir  strPASCALS  strFTS];
% optFTSDir = [rootDir  strPASCALS  strOptFTS]; 
% OTSDir =  [rootDir  strPASCALS  strOTS];
% EvaluationOnPASCALS(FTSDir,optFTSDir,OTSDir);
% 
% FTSDir = [];
% optFTSDir = [];
% OTSDir =  [];

% 
% %% on MSRA-10k ======================================
strMSRA10k = 'MSRA-10k-20191129\';
FTSDir = [rootDir  strMSRA10k  strFTS];
optFTSDir = [rootDir  strMSRA10k  strOptFTS];
OTSDir =  [rootDir  strMSRA10k  strOTS];
EvaluationOnMSRA10k(FTSDir,optFTSDir,OTSDir);