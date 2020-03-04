%% Compute SVD using union of connected components' SVDs (to improve speed)
%
% Inputs: 
%           - A:        SQUARE adjacency matrix 
%                       (this can be extended to non-square if desired) 
%           - Lnrm:     Laplacian matrix corresponding to A
%           - feedback: To display process or not
%
% Outputs: 
%           - sl:       Vector of singular values
%           - Vl:       V-matrix in SVD decomposition Lnrm = U*S*V'
%
%% Ver:
%
%
%
function [sl,Vl] = BlockSVD(A, Lnrm)

sizA = size(A,1);

% Run BFS to find graph communities
labels = GraphConnectedComp(A); % Label graph components 


numCom = max(labels); % Number of graph communities 
V = zeros(sizA); % Initialize matrix of eigenvectors
sv = zeros(sizA,1); % Vector of singular values
for i = 1 : numCom
    idx = (labels == i); % Nodes that belong to community i
    Li = Lnrm(idx,idx); % Part of matrix corresponding to the community
    [~,Si,Vi] = svd(Li); % SVD of Li block
    V(idx,idx) = Vi; % Store Vi in corresponding part of Vl
    sv(idx,:) = diag(Si); % Store singular values
end

% Sort eigenvalues and vectors
[sl, srtIdx] = sort(sv, 'descend');
Vl = V(:, srtIdx);







































































































