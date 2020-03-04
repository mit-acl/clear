%% Benchmark multi-way matching algorithms
%
% Input:        
%
%           - Pb:       Aggregate permutation matrix (baseline)
%           - Pr:       Aggregate permutation matrix (ground truth)
%           - numSmp:   Number of samples for each agent
%           - numAgt:   Number of agents 
%           - parIn:    Other input parameters
%
% Outputs:
%
%           - parOut:           Contains results 
%
%
% If this package is useful, please consider citing:
%
% [1] K. Fathian, K. Khosoussi, P. Lusk, Y. Tian, J.P. How, "CLEAR: A 
%     Consistent Lifting, Embedding, and Alignment Rectification Algorithm 
%     for Multi-Agent Data Association", arXiv:1902.02256, 2019.
%
%
% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU lesser General Public License, either version 
% 3, or any later version. This program is distributed in the hope that it 
% will be useful, but WITHOUT ANY WARRANTY. 
%
% (C) Kaveh Fathian, 2019.  Email: kaveh.fathian@gmail.com
%
%% Changes: 
%          - 
%
function results = CompareAlgs(Pb, Pr, numSmp, numAgt, parIn, varargin)
%% Parse input

feedback = false; % Dispay execution details, can be 'false' or 'true' 

ivarargin = 1;
while ivarargin <= length(varargin)
    switch lower(varargin{ivarargin})
        case 'feedback'
            ivarargin = ivarargin+1;
            feedback = varargin{ivarargin};       
        otherwise
            fprintf('Unknown option ''%s'' is ignored!',varargin{ivarargin});
    end
    ivarargin = ivarargin+1;
end


%  Parameters
runMchlft = parIn.runMchlft;  % Flag to execute the MatchLift algorithm 
runMchALS = parIn.runMchALS;  % Flag to execute the MatchALS algorithm 
runNMFSync = parIn.runNMFSync; % Flag to execute the NMFSync algorithm
runSpec = parIn.runSpec;
runSpecKF = parIn.runSpecKF;
runMchEig = parIn.runMchEig;
runQMch = parIn.runQMch;
runCLEAR = parIn.runCLEAR;

if isfield(parIn,'estimateNumObj')
    estimateNumObj = parIn.estimateNumObj; % Flag to estimate the number of objects or use the ground truth number
else
    estimateNumObj = true;
end


%% Estimate size of universe (i.e., the total number of unique objects)

if estimateNumObj
    Pin = Pb;
    idxSum = [0, cumsum(numSmp)]; % Cumulative index
    for i = 1 : numAgt % Remove any self associations (due to distinctness constraint)
        idxi = [idxSum(i)+1 : idxSum(i+1)];
        Pin(idxi,idxi) = eye(numSmp(i)); % Block of P associated to agent i
    end    
    Lb = P2L(Pin); % Transform permutation matrix to Laplacian    
    numObjEst = EstimateNumObj(Lb, 'numsmp',numSmp, 'method','fixed', 'thresh', 0.5);
else % use ground truth
    numObjEst = parIn.numObj;
end


%% Run all algorithms

PrmBin = {}; % Cell containing all recovered aggregate permutation matrices
TimBin = {}; % Cell containing all execution times
AlgBin = {}; % Cell containing name of executed algorithms



% Spectral method that works for partial permutations (Xiaowei Zhou's implementation)
if runSpec
    if feedback, fprintf('Running Spectral (Zhou et al.)...\n'); end
    tic
    P_spec = mmatch_spectral(Pb,numSmp,numObjEst);
    t_spec = toc;
    PrmBin{end+1} = double(full(P_spec));
    TimBin{end+1} = t_spec;
    AlgBin{end+1} = 'Spectral (Zhou et al.)';
end


% Cycle consistent Spectral method (Kaveh Fathian's implementation)
if runSpecKF
    if feedback, fprintf('Running Consistent Spectral...\n'); end
    tic
    P_spec2 = SpectralKF(Pb,numSmp,numObjEst,numAgt);
    t_spec2 = toc;
    PrmBin{end+1} = double(full(P_spec2));
    TimBin{end+1} = t_spec2;
    AlgBin{end+1} = 'Consistent Spectral';
end


% QuickMatch method - (Roberto Tron's implementation)
if runQMch
    if feedback, fprintf('Running QuickMatch...\n'); end
    tic
    P_QMch = QuickMatch(Pb, numSmp, 'numObj',numObjEst);
    t_QMch = toc;
    PrmBin{end+1} = double(full(P_QMch));
    TimBin{end+1} = t_QMch;
    AlgBin{end+1} = 'QuickMatch';
end


% MatchEig method - Partial permutations (Maset et al.'s implementation)
if runMchEig
    if feedback, fprintf('Running MatchEIG...\n'); end
    tic
    threshEig = 0.25; % Set threshold as specified by authors in their paper
    P_eig = MatchEIG(Pb,numObjEst,numAgt,numSmp.',threshEig);
    t_eig = toc;
    PrmBin{end+1} = double(full(P_eig));
    TimBin{end+1} = t_eig;
    AlgBin{end+1} = 'MatchEIG';
end


% NMFSync method -(Florian Bernard's implementation)
if runNMFSync
    if feedback, fprintf('Running NMFSync...\n'); end
    tic
    P_nmf = nmfSync(Pb,numSmp.', numObjEst);
    t_nmf = toc;
    PrmBin{end+1} = double(full(P_nmf));
    TimBin{end+1} = t_nmf;
    AlgBin{end+1} = 'NMFSync';
end



% CLEAR algorithm - (Kaveh Fathian's implementation)
if runCLEAR
    if feedback, fprintf('Running CLEAR...\n'); end
    tic
    P_clear = CLEAR(Pb, numSmp, numAgt, 'numObj',numObjEst);
    t_clear = toc;
    PrmBin{end+1} = double(full(P_clear));
    TimBin{end+1} = t_clear;
    AlgBin{end+1} = 'CLEAR';
end


% MatchALS method (Xiaowei Zhou's implementation)
if runMchALS
    if feedback, fprintf('Running MatchALS...\n'); end
    tic
    P_mchals = mmatch_CVX_ALS(Pb,numSmp,'univsize',2*numObjEst, 'maxiter', 200, 'verbose', false);
    t_mchals = toc;
    PrmBin{end+1} = double(full(P_mchals));
    TimBin{end+1} = t_mchals;
    AlgBin{end+1} = 'MatchALS';
end



% MatchLift method (Xiaowei Zhou's implementation)
if runMchlft
    if feedback, fprintf('Running MatchLift...\n'); end
    tic
    P_mchlft = MatchLift(Pb,numSmp,numObjEst);
    t_mchlft = toc;
    PrmBin{end+1} = double(full(P_mchlft));
    TimBin{end+1} = t_mchlft;
    AlgBin{end+1} = 'MatchLift';
end



% Add baseline to the stack
if feedback, fprintf('Done.\n'); end
PrmBin{end+1} = Pb;
TimBin{end+1} = 0;
AlgBin{end+1} = 'Baseline';




%% Output

% Initiate variables:
numAlg = length(AlgBin); % Number of executed algorithms
tBin = zeros(1,numAlg); % Execution times
prmBin = zeros(1,numAlg); % Check for permutation matrix structure
ccBin = false(1,numAlg); % Check for cycle consistency of results
errBin = zeros(1,numAlg); % Error metric
precision = zeros(1,numAlg); % Precision
recall = zeros(1,numAlg); % Recall

for i = 1 : numAlg    
    tBin(i) = TimBin{i};
    
    % Check if componenets are permutations
    prmFlg = CheckPerm(PrmBin{i}, numSmp, numAgt);
    prmBin(i) = prmFlg;
    
    % Check if results are cycle consistent
    ccBin(i) = CheckConsistency(PrmBin{i}, numAgt, numSmp);
    
    % Compute corresponding error for each algorithm 
    [erri, ~, p,r] = ErrorMetric(PrmBin{i}, Pr, Pb, numSmp, numAgt, 'fscore');
    errBin(i) = 1 - erri; % F-score is 1-erri
    precision(i) = p;
    recall(i) = r;
end


% Make matrices sparse to save space
for i = 1 : numAlg 
    PrmBin{i} = sparse(PrmBin{i});
end


% Output results
results.PrmBin = PrmBin;
results.numObjEst = numObjEst;
results.AlgBin = AlgBin;
results.errBin = errBin;
results.tBin = tBin; 
results.prmBin = prmBin;
results.ccBin = ccBin;
results.numSmp = numSmp;

results.precision = precision;
results.recall = recall;






















































































