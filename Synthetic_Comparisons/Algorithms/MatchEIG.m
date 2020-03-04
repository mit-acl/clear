function Zout = MatchEIG(Z,d,n,dimP,t)
% MATCHEIG performs multi-view matching starting from (noisy) pairwise matches
%       This function implement an efficient closed-form solution (based on
%       a spectral decomposition) to solve the multi-view matching problem.
% ----- Input:
%       Z: permutation matrix representing the input matches
%       d: estimate of universe size
%       n: number of images
%       dimP: size of each permutation
%       t: threshold
% ----- Output:
%       Zout: permutation matrix representing the output matches
% ----- Authors:
%       Eleonora Maset, Federica Arrigoni and Andrea Fusiello, 2017 
%       Practical and Efficient Multi-view Matching, ICCV17

sZ = size(Z,1);
% inizialize output matrix Zout
Zout = sparse(sZ,sZ);
% retrieve the indices for each block (pairwise permutation)
m = [0;cumsum(dimP(1:end-1))];
blk = @(k) 1+m(k):m(k)+dimP(k);

% spectral decomposition
[U,Ds] = eigs(Z,d,'lm');
U = real(U)*sqrt(abs(Ds));

for i = 1:n
    Zout(blk(i),blk(i)) = eye(dimP(i));
    for j = i+1:n
       Zb = U(blk(i),:)*U(blk(j),:)';
       % thresholding
       Zb(Zb<t) = 0; 
       % project onto permutation
       Zout(blk(i),blk(j)) = matrix2permutation(Zb);
       Zout(blk(j),blk(i)) = Zout(blk(i),blk(j))';
   end
end

end
