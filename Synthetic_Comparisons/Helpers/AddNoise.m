%% Add random binary noise to the elements of permutation matrix
%
% Inputs:
%
%           - TT:       Initial permutations (aka. correspondences or score matrices)
%           - misPerc:  Percentage of mismatches
%           - numSmp:   Number of observations for each agent
%           - numObj:   Number of objects in the universe
%           - numAgt:   Number of agents (aka. frames or observations)
%           - adj:      Adjacency matrix
%
% Outputs:
%
%           - TT_mis:  Modified permutations
%
%
% Options:
%
%           - 'symmetric':  Determines if the noise should be added in a 
%                           symmetric fashion to the permutation matrix
%
%
%% Ver 1_0:
%           - Initial implementation
%
%
%
function TT_mis = AddNoise(TT, misPerc, numSmp, numObj, numAgt, adj, varargin)


% Options and parameters
idxSum = [0, cumsum(numSmp)]; % Cumulative index
symmetric = false;

ivarargin = 1;
while ivarargin <= length(varargin)
    switch lower(varargin{ivarargin})
        case 'symmetric'
            symmetric = true;
        otherwise
            fprintf('Unknown option ''%s'' is ignored!',varargin{ivargin});
    end
    ivarargin = ivarargin+1;
end


%% 

% Find index of all elements that can be modified
numElm = numel(TT);
idxMat = zeros(2, numElm); % Each colunm is an index

numIdx = 0;

if symmetric % If 'symmetric' option is on

for i = 1 : numAgt-1
    idxi = [idxSum(i)+1 : idxSum(i+1)];
    for j = i+1 : numAgt        
        idxj = [idxSum(j)+1 : idxSum(j+1)];
        
        if adj(i,j)
            for ii = 1 : length(idxi)
                for jj = 1 : length(idxj)
                    numIdx = numIdx + 1;
                    idxMat(:, numIdx) = [idxi(ii); idxj(jj)];
                end
            end
        end
        
    end
end

else
    
for i = 1 : numAgt
    idxi = [idxSum(i)+1 : idxSum(i+1)];
    for j = setdiff(1:numAgt, i)        
        idxj = [idxSum(j)+1 : idxSum(j+1)];
        
        if adj(i,j)
            for ii = 1 : length(idxi)
                for jj = 1 : length(idxj)
                    numIdx = numIdx + 1;
                    idxMat(:, numIdx) = [idxi(ii); idxj(jj)];
                end
            end
        end
        
    end
end    
    
end

% Remove unassigned indices
idxMat(:, numIdx+1:end) = [];


%% Choose index of elements that should be chagnged randomly

numNos = round( (misPerc/100) * numIdx ); % Number of elements that should be changed

% Random draw
idxNos = randi(numIdx, 1, numNos);


TT_mis = (TT > 0.5); % Initialize as logical array

% Add noise
for i = 1 : numNos
    ii = idxNos(i);
    TT_mis( idxMat(1,ii), idxMat(2,ii) ) = ~TT_mis( idxMat(1,ii), idxMat(2,ii) ); % Swap 0s and 1s

    if symmetric
        TT_mis( idxMat(2,ii), idxMat(1,ii) ) = TT_mis( idxMat(1,ii), idxMat(2,ii) );
    end
end

% Return as double
TT_mis = double(TT_mis);























end


























































































































