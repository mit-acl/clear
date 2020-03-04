%% CLEAR algorithm (Consistent Laplacian Estimatmion and Aberrancy Reduction)
%
% Inputs:
%
%           - TT:       Initial permutations (aka. correspondences or score matrices)
%           - numSmp:   Number of observations for each agent
%           - numAgt:   Number of agents (aka. frames or observations)
%
% Outputs:
%
%           - XX:       Consistent pariwise permutations
%           - X:        Map to universe (lifting permutations)
%           - numObj:   Estimated number of objects
%
% Options:
%
%           - 'numObj':     When the number of objects in the universe is
%                           provided. E.g., (..., 'numObj', 10)
%                           If 'numObj' is not specified it will be estimated
%                           from the sepctrum of Laplacian automatically. s
%
%
% If this program is useful, please cite:
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
%
%% Changes:
%
%
function [XX, X, numObj] = CLEAR(TT, numSmp, numAgt, varargin)
%% Parse input

% Preallocate paramters
numObj = -1; 

ivarargin = 1;
while ivarargin <= length(varargin)
    switch lower(varargin{ivarargin})
        case 'numobj'
            ivarargin = ivarargin+1;
            numObj = varargin{ivarargin};        
        otherwise
            fprintf('Unknown option ''%s'' is ignored!',varargin{ivarargin});
    end
    ivarargin = ivarargin+1;
end

idxSum = [0, cumsum(numSmp)]; % Cumulative index
numSmpSum = sum(numSmp); % Total number of observations

if ~(numSmpSum == size(TT,1))
    error('Incorrect number of samples.')
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%% CLEAR algorithm

P = (TT + TT')/2; % Make association matrix symmetric
for i = 1 : numAgt % Remove any self associations (distinctness constraint)
    idxi = [idxSum(i)+1 : idxSum(i+1)];
    P(idxi,idxi) = eye(numSmp(i)); % Block of P associated to agent i
end
A = P - diag(diag(P)); % Adjacency matrix of induced graph
L = P2L(P); % Graph Laplacian matrix


% Normalize L
Lnrm = NormalizeLap(L, 'normalize', 'DI', 'multtype', 'sym');


% Compute SVD using union of connected components' SVDs (to improve speed)
[sl,Vl] = BlockSVD(A, Lnrm);
% [~,Sl,Vl] = svd(Lnrm); sl = diag(Sl);


% Estimate size of universe if not provided
if numObj == -1
    numObj = EstimateNumObj(sl, 'eigval',true, 'numsmp',numSmp);
end


% Get the null space
U0 = Vl(:, end-numObj+1 : end); % Kernel
U = bsxfun(@rdivide, U0, sqrt(sum(U0.^2,2))); % Normalize each row of U0


% Find cluster center candidates (Can be improved??)
C = PivotRows(U, numObj); % Cluster centers


% Distance to cluster centers
F = 1 - U * C'; % Dot product with cluster centers (the minimum element indicates the optimal assignment)    


% Solve linear assignment
X = zeros(size(F));
for i = 1 : numAgt
    idxi = [idxSum(i)+1 : idxSum(i+1)];
    Fi = F(idxi, :); % Component of F associated to agent i
    
    % suboptimal linear assignment
    Xi = SuboptimalAssign(Fi);

    X(idxi, :) = Xi; % Store results
end


% Pairwise assignments
XX = X * X';







































































