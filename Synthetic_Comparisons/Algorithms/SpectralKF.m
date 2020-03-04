%% Parial spectral algorithm (Kaveh Fathian's implementation)
%
% Inputs:
%
%           - TT:       Initial permutations (aka. correspondences or score matrices)
%           - numSmp:   Number of observations for each agent
%           - numObj:   Number of objects in the universe
%           - numAgt:   Number of agents (aka. frames or observations)
%
% Outputs:
%
%           - TT_spec:     Consistent permutations
%
%
%% Ver: 
%           - Optimized: BFS to detect community and perform local
%                        eigendecomp, Hungarian algorithm is now an option 
%                        (for faster execution set 'hungarian' to false)
%           - Omitted orthonormalization step
%           - Changed implementation of 'Spectral_Ver1_2.m' to the parial 
%             permutation case using the pivoting idea.
% 
% 
function TT_spec = SpectralKF(TT, numSmp, numObj, numAgt, varargin)
%% Parse input

% Preallocate paramters
hungarian = true;

ivarargin = 1;
while ivarargin <= length(varargin)
    switch lower(varargin{ivarargin})
        case 'hungarian'
            ivarargin = ivarargin+1;
            hungarian = varargin{ivarargin};
        otherwise
            fprintf('Unknown option ''%s'' is ignored!',varargin{ivarargin});
    end
    ivarargin = ivarargin + 1;
end

idxSum = [0, cumsum(numSmp)]; % Cumulative index
numSmpSum = sum(numSmp); % Total number of observations

if ~(numSmpSum == size(TT,1))
    error('Incorrect number of samples.')
end


%% Spectral method

% SVD
[Ut,~,~] = svd(TT);
U = Ut(:, 1:numObj); % Bases for range of TT

% Us = bsxfun(@rdivide, U, sqrt(sum(U.^2, 2)) ); % Scale to get a permutation matrix with 1's on diagonal

% (Lifting) Get permutation to the universe
% Find pivot points 
[~,~,P] = lu(U, 'vector');
Up = U(P(1:numObj),:); % Pivot rows

% % Orthogonal procrustes:
% [Un, ~, Vn] = svd(Up); 
% Q = (Un * Vn')';

% Lifting permutation matrix
P0 = U / Up;

% Assignment
P = zeros(size(P0)); % Preallocate
for i = 1 : numAgt
    idxi = [idxSum(i)+1 : idxSum(i+1)];
    Pi = -P0(idxi, :);  % Component of P0 associated to agent i  (sign changed so that the minimum element indicates the assignment)
    
    if hungarian % If Hungarian algorithm is specified in the input
        Xi = OptimalAssign(Pi);
    else % suboptimal assignment
        Xi = SuboptimalAssign(Pi);
    end
    
    % Store results
    P(idxi,:) = Xi;
end

% Agent permutations
TT_spec = P * P';





































































































