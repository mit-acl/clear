%% Generate Synthetic data for benchmarking multi-way matching algorithms
%
% Inputs:
%           - parIn:    Consists of parameters needed for generating the
%                       synthetic data
%
% Outputs:
%           - parOut:   Generated ground truth and baseline (i.e., noisy) 
%                       data
%
%
%% Changes:
%
%
%
function [Pr, Pb, numSmp, numAgt, parOut] = SyntheticData(parIn)

% Load parameters
numAgt = parIn.numAgt;        % Number of agents
numObj = parIn.numObj;        % Number of world objects
smpMen = parIn.smpMen;        % Mean of number of object samples
smpStd = parIn.smpStd;        % Standard deviation of number of object samples
misPerc = parIn.misPerc;      % Mismatch percentage (0 - 100) 

numOut = zeros(1, numAgt);    % Number of outlier samples for each agent
noiseVar = 0;                 % Noise variance for random points
numDim = 2;                   % Dimension of random points
adj = ones(numAgt) - eye(numAgt); % Adjacency matrix


%% Generate ground truth pairwise matches

% Generate number of sampled objects for each agent
numSmp = round(smpMen + smpStd * randn(1,numAgt)) .* ones(1, numAgt);
numSmp(numSmp > numObj) = numObj; % Keep below numObj
numSmp(numSmp < 1) = 1; % Keep greater than 1

% Generate synthetic data (Pr is the ground truth aggregate permutation matrix)
[Obj, Pr, XXr, Prm] = GenRandObj(numObj, numAgt, numDim, numSmp, numOut, noiseVar);

Lr = P2L(Pr); % Ground truth Laplacian matrix


%% Add miamatches to the ground truth

% Generate baseline (noisy) matches by adding noise to ground truth
Pb = AddMismatch(Pr, misPerc, numSmp, numObj, numAgt, adj, 'Symmetric');

Lb = P2L(Pb); % Baseline Laplacian matrix


%%  Generate output

parOut = parIn;
parOut.numSmp = numSmp;
parOut.adj = adj;
parOut.Pr = Pr;
parOut.Pb = Pb;
parOut.XXr = XXr;
parOut.Prm = Prm;
parOut.Lr = Lr;
parOut.Lb = Lb;























































































































