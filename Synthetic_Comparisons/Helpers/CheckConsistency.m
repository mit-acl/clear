%% Check if a aggregate permutation matrix is consistent
%
% Inputs:
%           - TT:       An aggregate permutation matrix
%           - numAgt:   Number of agents
%           - numSmp:   Number of observations for each agent
%
% Output:
%
%           - chk:      Is 'true' is consistency holds, otherwise it is 'false'
%
%% Ver:
%           - Check consistency based on clustering
%
function chk = CheckConsistency(TT, numAgt, numSmp)

idxSum = [0, cumsum(numSmp)]; % Cumulative index
numSmpSum = sum(numSmp); % Total number of observations


% Find connected componenets via BFS algorithm
G = graph(TT - eye(size(TT))); % Define graph via Adjacency matrix
clusIdx = conncomp(G); % Cluster graph connected components

% Permutation based on clustering
TT_clus = zeros(size(TT));

% Reconstruct "clustered" aggregate permutation matrix
for i = 1 : numSmpSum
    TT_clus(i,i) = 1;
    for j = i+1 : numSmpSum
        if clusIdx(i) ~= clusIdx(j)
            TT_clus(i,j) = 0;
            TT_clus(j,i) = 0;
        else
            TT_clus(i,j) = 1;
            TT_clus(j,i) = 1;
        end
    end
end


% Check if both permutation matrices are the same
if all(TT(:) == TT_clus(:))
    chk = true; % Set chk to true (i.e., consistent). 
else
    chk = false;
end















































































































