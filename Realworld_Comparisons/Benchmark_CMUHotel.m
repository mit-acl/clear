%% Comparison results for CMU Hotel dataset
% 
% 
% Notes:
%           - Based on SIFT features from VLFeat library
%
%% Set path

addpath('Helpers');
addpath(genpath('..\CLEAR_Matlab'));
addpath(genpath('..\Synthetic_Comparisons\Algorithms'));
addpath(genpath('..\Synthetic_Comparisons\Helpers'));
addpath(genpath('VLFeat\toolbox\mex'));

% Path to CMU Hotel dataset
dataRoot = [pwd, '\Datasets\CMU Hotel']; 

% addpath('F:\Hubic\Code\Matlab\MIT\03.5 - CLEAR - paper results\VLFeat\toolbox\mex\mexw64');


%% Process dataset to extract groundtruth and image feature point data


benchName = 'hotel';
[Pr, numSmp, numAgt, numObj, imgDes, parOut0] = Process_CMUHotel(dataRoot, benchName, 'save', false);


%% Loop over outlier rejection ratios for baseline matching

% Lowe's outlier rejection ratios for the baseline
ratios = 1.5;

% Preallocate varibales that store results
numRto = length(ratios);
preBin = cell(numRto,1);
recBin = cell(numRto,1);
pcBin = cell(numRto,1);
ccBin = cell(numRto,1);
errBin = cell(numRto,1);
timBin = cell(numRto,1);
numObjEst = zeros(numRto,1);
PbBin = cell(numRto,1);

% Run algorithms or not. Can be 'true' or 'false'
parIn.runMchlft = false;
parIn.runMchALS = true;
parIn.runNMFSync = true;
parIn.runSpec = true;
parIn.runSpecKF = false;
parIn.runMchEig = true;
parIn.runQMch = true;
parIn.runCLEAR = true;


parIn.estimateNumObj = true;

for i = 1 : numRto
    % Baseline correspondence: Matching descriptors with Lowe's ratio test
    [Pb, Xb] = Match_Features(imgDes, numSmp, numAgt, 'ratio', ratios(i)); % Match features across all images using descriptors
    
    % Execute multi-way matching algorithms    
    parOut = CompareAlgs(Pb, Pr, numSmp, numAgt, parIn, 'feedback', true); % Run all algorithms     
    
    % Store results
    preBin{i} = parOut.precision; % Precision
    recBin{i} = parOut.recall; % Recall
    errBin{i} = parOut.errBin; % Error (Fscore)
    ccBin{i} = parOut.ccBin; % Cycle consistency check
    pcBin{i} = (parOut.prmBin == 1); % Permutation check
    timBin{i} = parOut.tBin; % Execution times
    numObjEst(i) = parOut.numObjEst;
    PbBin{i} = Pb;  % Baseline match
end



%% Table of precision-recall results

AlgBin = parOut.AlgBin;
numAlg = size(AlgBin,2); % Number of algorithms

% Precision table
Tp = table(AlgBin', 'VariableNames',{'Precision'});
for i = 1 : numRto
    Tp = addvars(Tp, preBin{i}', 'NewVariableNames',{strcat('ratio',num2str(i))});   
end


% Recall table
Tr = table(AlgBin', 'VariableNames',{'Recall'});
for i = 1 : numRto
    Tr = addvars(Tr, recBin{i}', 'NewVariableNames',{strcat('ratio',num2str(i))});   
end


% F-score table
Tf = table(AlgBin', 'VariableNames',{'Fscore'});
for i = 1 : numRto
    Tf = addvars(Tf, errBin{i}', 'NewVariableNames',{strcat('ratio',num2str(i))});   
end


% Time table
Tt = table(AlgBin', 'VariableNames',{'Time'});
for i = 1 : numRto
    Tt = addvars(Tt, timBin{i}', 'NewVariableNames',{strcat('ratio',num2str(i))});   
end





disp('Precision table:')
Tp

disp('Recall table:')
Tr

disp('Time table:')
Tt
































































