%% Preallocate variables
%
%
%
function data = Data_Allocate(rangeX, rangeY, numItr)

numI = length(rangeX);
numJ = length(rangeY);
Err = cell(numI, numJ, numItr);     % Errors (1 - Fscore)
Pre = cell(numI, numJ, numItr);     % Precision
Rec = cell(numI, numJ, numItr);     % Recall
Tim = cell(numI, numJ, numItr);     % Execution times
Prm = cell(numI, numJ, numItr);     % Output of algorithms
Smp = cell(numI, numJ, numItr);     % Number of objects observed by agents
NumObjEst = cell(numI, numJ, numItr); % Number of estimated objects
PrmFlg = cell(numI, numJ, numItr);  % Permutation matrix check
ConsFlg = cell(numI, numJ, numItr); % cycle consistency check


data.rangeX = rangeX;
data.rangeY = rangeY;
data.numI = numI;
data.numJ = numJ;
data.numItr = numItr;
data.Err = Err;
data.Pre = Pre;
data.Rec = Rec;
data.Tim = Tim;
data.Prm = Prm;
data.Smp = Smp;
data.NumObjEst = NumObjEst;
data.PrmFlg = PrmFlg;
data.ConsFlg = ConsFlg;




















































































































