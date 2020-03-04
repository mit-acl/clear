%% Makes an aggregate permutation matrix given a Laplacian matrix 
%
function P = L2P(L)

% Generate Laplacian matrix
P = -L;
P = P - diag(diag(P)) + eye(size(P)); 


















































