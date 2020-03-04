%% Makes a Laplacian matrix out of a aggregate permutation matrix
%
%
function L = P2L(P)

% Generate Laplacian matrix
PP = P - diag(diag(P));
L = diag(sum(PP,2)) - PP; 


















































