% This function is part of the NmfSync algorithm for the synchronisation of
% partial permutation matrices, as described in [1]. When you use this
% code, you are required to cite [1].
%
% [1] Synchronisation of Partial Multi-Matchings via Non-negative
% Factorisations F. Bernard, J. Thunberg, J. Goncalves, C. Theobalt.
% Pattern Recognition. 2019
%
%
% Input:
%           W               Matrix of pairwise matchings that is to be
%                           synchronised
%                           (size m-by-m, where m = sum(dimVector))
%           dimVector       k-dimensional vector that contains m_1,...m_k,
%                           where m_i is the number of points for the i-th
%                           object
%           d               scalar dimensionality of desired universe size
%           eigMode         determines which eigensolver is used ('eig' or
%                           'eigs')
%           theta           scalar threshold for pruning bad matchings
%           verbose         flag that indicates whether verbose output is
%                           used (true or false)
%
% Output:
%           Wout           Matrix of synchronised pairwise matchings
%                          (m-by-m)
%           U              Object-to-universe matching matrix (m-by-d2).
%                          Note that d2 may not be exactly equaL to d
%                          (e.g. due to the pruning)
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

function [Wout, U] = nmfSync(W, dimVector, d, eigMode, theta,  verbose)
    m = size(W,1);
    
    largerInstanceSize = 15000; % if Wsize > largerInstanceSize, we use eigs()
    if ( ~exist('eigMode', 'var') || isempty(eigMode))
        if ( m > largerInstanceSize )
            eigMode = 'eigs';
        else
            eigMode = 'eig';
        end
    end
    
    if ( ~exist('theta', 'var') || isempty(theta) )
        theta = 0;
    end
    
    if ( ~exist('verbose', 'var') )
        verbose = 0;
    end
    
    
    W = .5*(W + W'); % make matrix symmetric
    
    %% init
    if ( verbose )
        disp(['INIT: Running ' eigMode '() ...']);
    end
    
    
    switch eigMode
        case 'eigs'
            % for very large problems we use eigs
            [V,eval] = eigs(sparse(W),d,'la');
        case 'eig'
            [U,eval] = eig(full(W));
            V = U(:,end-d+1:end);
            clear U;
    end
    if ( verbose )
        disp(['INIT: Running ' eigMode '()...DONE']);
    end
    
    eval = diag(eval);
    eval = eval(end-d+1:end);
    V = V*diag(sqrt(eval)); % scale eigenvectors according to sqrt(eigenvalues)
    
    V = V*diag(sign(sum(V,1))); % fix signs
    
    V = SBRA(V, d, dimVector);
    
    V = V*diag(sign(sum(V,1))); % fix signs
    
    V(V < 0) = 0; % enforce nonnegativity
    
    %% NMF
    if ( verbose )
        disp(['MAIN: Running nnmf()...']);
    end
    
    if ( m > largerInstanceSize )
        % Note: a custom version of Matlab's nnmf() function for nonegative matrix
        % factorisation method has been used to obtain better memory efficiency. Due
        % to license restrictions this file cannot be provided.
        warning('nnmfMemoryEfficient() not available, resorting to nnmf(). For large problems this may lead to memory issues.');
    end
    
    [V,H] = nnmf(W, size(V,2), 'w0', V,'h0', V', 'algorithm', 'mult');
    
    if ( verbose )
        disp(['MAIN: Running nnmf()...DONE']);
    end
    
    % scale V and H
    Vlen = sqrt(sum(V.^2,1));
    Vlen(Vlen==0) = 1;
    V = bsxfun(@times,V,1./sqrt(Vlen));
    %     H = bsxfun(@times,H,sqrt(Vlen')); % H is not used
    
    %% rounding
    if ( verbose )
        disp(['PROJ: Running SBRA()...']);
    end
    
    Urot = SBRA(V,  d, dimVector);
    
    if ( verbose )
        disp(['PROJ: Running SBRA()...DONE']);
    end
    
    Urot = Urot*diag(sign(sum(Urot,1))); % fix signs
    
    if ( verbose )
        disp(['PROJ: Solving LAP...']);
    end
    
    U = projectOntoPartialPermBlockwise(Urot, dimVector, [], 0);
    
    if ( verbose )
        disp(['PROJ: Solving LAP...DONE']);
    end
    
    % perform pruning of bad matchings
    vals = Urot(U>0);
    [r,c] = find(U>0);
    
    badIdx = vals<theta;
    r = r(badIdx);
    c = c(badIdx);
    
    for i=1:numel(c)
        if ( nnz(U(:,c(i))) > 1 )
            U(r(i),c(i)) = 0; % remove bad matching
            U(r(i),end+1) = 1; % add new (self)-matching
        end
    end
    
    % remove all zero columns (which may arise from pruning)
    U(:,sum(U,1)==0) = [];
    
    
    Wout = U*U';
end

