% This function is part of the NmfSync algorithm for the synchronisation of
% partial permutation matrices, as described in [1]. When you use this
% code, you are required to cite [1].
% 
% [1] Synchronisation of Partial Multi-Matchings via Non-negative
% Factorisations F. Bernard, J. Thunberg, J. Goncalves, C. Theobalt.
% Pattern Recognition. 2019
%
% 
% Author & Copyright (C) 2019: Florian Bernard (f.bernardpi[at]gmail[dot]com)
%
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU Affero General Public License as published
% by the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Affero General Public License for more details.

% You should have received a copy of the GNU Affero General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
function [Urot, C] = SBRAstep(U, dimVector, Cinit, startColIdx, rowIdxToConsider)
    D = size(U,2);

    if ( ~exist('Cinit', 'var') )
        C = zeros(sum(dimVector),D);
    else
        C = Cinit;
    end
    
    nRowIdx = numel(rowIdxToConsider);

    colIdx = startColIdx:min(startColIdx + nRowIdx,D);
    C(rowIdxToConsider,colIdx) = eye(nRowIdx, numel(colIdx));

    [u,~,v] = svd(U'*C);
    Q = u*v';
    
    Urot = U*Q;
    signSum = sign(sum(Urot,1));
    Urot = Urot*spdiags(signSum(:),0,numel(signSum),numel(signSum));
end