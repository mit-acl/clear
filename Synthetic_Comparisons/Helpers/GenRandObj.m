%% Generate random world objects
%
% Inputs:
%
%           - numObj:   Number of objects in the universe
%           - numAgt:   Number of agents (aka. frames or observations)
%           - numDim:   Dimension of objects
%           - numSmp:   Number of sampled objects for each agent
%           - numOut:   Number of outliers
%           - noiseVar: Noise variance
%
% Outputs:
%
%           - Obj:     Sampled objec set by agents
%           - TT_true: Ground truth permutation matrix
%           - XX_true: Ground truth permutations from samples to universe
%           - Prm:     Permutation indices
%
%
%% Changes:
%           - Extension to partial matches
%           - Intial implementation
%
%
function [Obj, TT_true, XX_true, Prm] = GenRandObj(numObj, numAgt, ...
    numDim, numSmp, numOut, noiseVar)

% Parameters
numSmpSum = sum(numSmp); % Total number of observations
idxSum = [0, cumsum(numSmp)]; % Cumulative index
Objwrd = rand(numDim,numObj); % Random points

% Generate sets of object samples + noise + outliers
Obj = cell(1, numAgt);
Prm = cell(1, numAgt);
for i = 1 : numAgt
    idx = randperm(numObj);
    idxi = idx(1:numSmp(i));
    Prm{i} = idxi;
    Obj{i} = Objwrd(:,idxi); 
    Obj{i} = [Obj{i}, rand(numDim, numOut(i))]; % Add outliers
    Obj{i} = Obj{i} + noiseVar * randn(size(Obj{i})); % Add noise
end

% Groud truth permutations (each Xii maps world objects to agent: ^i{Xii}_w
XX_true = cell(numAgt, numAgt);
for i = 1 : numAgt                      
    % Permutation matrix
    Xii = zeros(numSmp(i), numObj);
    p = Prm{i};
    for ii = 1 : numSmp(i)
        Xii(ii,p(ii)) = 1;
    end

    XX_true{i,i} = Xii;
end
for i = 1 : numAgt-1
    for j = i+1 : numAgt                
        
        % Permutation matrix
        Xii = XX_true{i,i};
        Xjj = XX_true{j,j};
        Xij = Xii * Xjj';
        
        XX_true{i,j} = Xij;
        XX_true{j,i} = Xij';
    end
end


% Aggregate permutation matrix
TT_true = zeros(numSmpSum);
for i = 1 : numAgt
    idxi = [idxSum(i)+1 : idxSum(i+1)];
    for j = i+1 : numAgt
        idxj = [idxSum(j)+1 : idxSum(j+1)];
        TT_true(idxi, idxj) = XX_true{i,j};
        TT_true(idxj, idxi) = (XX_true{i,j})';
    end
    TT_true(idxi, idxi) = XX_true{i,i} * (XX_true{i,i})';
end

