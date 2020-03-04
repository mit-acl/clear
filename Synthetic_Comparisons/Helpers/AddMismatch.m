%% Add miamatch to ground truth data
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
%           - 'Symmetric':  Can be 'on' or 'off'. Determines if the noise 
%                           should be added in a symmetric fashion to the
%                           permutation matrix
%
%
%% Changes: 
%           - Extension to partial matches
%
%
function TT_mis = AddMismatch(TT, misPerc, numSmp, numObj, numAgt, adj, varargin)

% Parameters
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

TT_mis = TT; % Initialize

numMisMat = zeros(numAgt); % Max number of inter-agent mismatches 
for i = 1 : numAgt-1
    for j = i+1 : numAgt
        if adj(i,j)
            numMisMat(i,j) = min([numSmp(i),numSmp(j)]);
            numMisMat(j,i) = numMisMat(i,j);            
        end
    end
end
numMisTot = sum(numMisMat(:)); % Total number of mismatches that can occur

if symmetric  
    numMisTot = numMisTot / 2; % Half of possible number
    adj =  triu(adj); % Only the upper triangular part
    TT_mis = triu(TT_mis); % Only the upper triangular part
    numMisMat = numMisMat .* adj; % Only the upper triangular part
end

numMis = round((misPerc/100) * numMisTot); % Number of mismatches to be added


% Generate random numbers for mismatch instances in the matrix 
x = randi([0, numObj], numAgt,numAgt) .* adj; % Random number of mismatches in each permutation matrix
x = min(x,numMisMat);
xSum = sum(x(:));
while xSum ~= numMis % Randomly distribute the number of mismatches among the elements of x
    xdiff = xSum - numMis; % Difference between current # of mismatches and desired #
    sgn = sign(xdiff); 
    dif = abs(xdiff);   
    if sgn > 0 % Index of elements with positive value
        idx = (x > 0) ;
        numBin2 = nnz(idx);
    else % Index of elements with value < max allowed
        idx = (x < numMisMat) ;
        numBin2 = nnz(idx);
    end
    d = floor(dif/numBin2); % Quotient
    r = mod(dif,numBin2); % Remainder
    if sgn > 0 % Subtract numbers to acheive desired # of mismatches
        x(idx) = x(idx) - d;
        [idxr, idxc] = find(x > 0);
        for i = 1 : min(r, length(idxr))
            x(idxr(i),idxc(i)) = x(idxr(i),idxc(i)) - 1;
        end
    else % Add numbers to acheive desired # of mismatches
        x(idx) = x(idx) + d;
        [idxr, idxc] = find(x < numMisMat);
        for i = 1 : min(r, length(idxr))
            x(idxr(i),idxc(i)) = x(idxr(i),idxc(i)) + 1;
        end
    end
    
    x(x < 0) = 0; % Keep elements of 'x'  positive
    [idxr, idxc] = find(x > numMisMat);
    for i = 1 : length(idxr) % Keep elements of 'x' less than max allowed
        x(idxr(i),idxc(i)) = numMisMat(idxr(i),idxc(i));
    end
    
    xSum = sum(x(:)); % Current number of mismatches
end



% Add random mismatches to the permutation matrix
for i = 1 : numAgt
    idxi = [idxSum(i)+1 : idxSum(i+1)];
    for j = 1 : numAgt        
        idxj = [idxSum(j)+1 : idxSum(j+1)];
        
        if adj(i,j) 
            xij = x(i,j); % Number of mismatches to be added
            Tij = TT(idxi, idxj); % Permutation matrix between agents i,j
            
            if xij == 0 % Skip if no mismatch should be added
                continue;
            end
            
            if xij == 1 % If one mismatch should be added
                if size(Tij,1) == numMisMat(i,j)
                    Tij(1,:) = circshift(Tij(1,:), 1); % Change first rows
                else
                    Tij(:,1) = circshift(Tij(:,1), 1); % Change first columns
                end
            else % If more than one mismatch should be added
                p = randperm(numMisMat(i,j), xij); % Draw 'xij' random permutaions from 1:numMisMat(i,j)                
                pc = circshift(p,1);
                
                if size(Tij,1) == numMisMat(i,j)
                    Tij(p,:) = Tij(pc,:); % Swap rows
                else
                    Tij(:,p) = Tij(:,pc); % Swap columns
                end                
            end
            
            % Save to matrix
            TT_mis(idxi, idxj) = Tij;            
            
        end
        
    end
end


if symmetric % Make TT_mis symmetric
    TT_mis = TT_mis + TT_mis.' - diag(diag(TT_mis));
end

















































































