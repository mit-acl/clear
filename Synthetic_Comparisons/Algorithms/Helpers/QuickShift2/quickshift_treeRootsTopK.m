%Return indices of k roots of the trees with the highest density
%function idxRoots=quickshift_treeRootsTopK(treeEdges,density,k)
%Inputs
%   treeEdges   Edges from the Quickshift forest (parent for each node)
%   density     Value of the density for each node
%   k           Nb of roots to return
%Note: quickshift_treeRoots returns an indicator variable. This function
%returns indeces.
function idxRootsTopK=quickshift_treeRootsTopK(treeEdges,density,k)

idxRoots=quickshift_treeRoots(treeEdges,'indeces');
[~,idxIdxRootsTopK]=maxk(density(idxRoots),k);
idxRootsTopK=idxRoots(idxIdxRootsTopK);
