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

function Urot = SBRA(U, D, m)
    U = U*diag(sign(sum(U,1))); % fix sign
    
    vec = @(x) x(:);
    
    % initialise variables
    C = sparse(size(U,1), size(U,2));
    startColIdx = 1;
    
    % rowToBlockIndexMap is an m-dimensional vector that indicates for each
    % row of U to which block index it belongs
    rowToBlockIndexMap = [];
    for i=1:numel(m)
        rowToBlockIndexMap = [rowToBlockIndexMap; ...
            i*ones(m(i),1)];
    end
    
    % find block index of largest block
    [~,maxIdx] = max(m);
    
    cumDim = [0; cumsum(m)];
    rowIndices = cumDim(maxIdx)+1:cumDim(maxIdx+1);

    autoThreshold = [];
    while (1 )
        [Urot, C] = SBRAstep(U, m, C, startColIdx, rowIndices);

        startColIdx = startColIdx + numel(rowIndices);
        
        if ( startColIdx > D  )
            break;
        end
        
        % set threshold (only once)
        if ( isempty(autoThreshold) )
            autoThreshold = median(vec(Urot(C>0)))/2;
        end
        
        % update currU and currDimVector
        inactiveIdx = (find(max(Urot(:,1:startColIdx-1), [], 2) < autoThreshold));
        
        if ( isempty(inactiveIdx) )
            break;
        end
        
        currDimVector = accumarray(rowToBlockIndexMap(inactiveIdx),1);
        [~,maxIdx] = max(currDimVector); % use largest block

        % update C
        C(:,1:startColIdx-1) = Urot(:,1:startColIdx-1) >= autoThreshold;
        
        % ensure that at most one element per row in C is nonzero
        moreThanOneRowIdx = find(sum(C,2)>1);
        for jj=1:numel(moreThanOneRowIdx)
            currCols = find(C(moreThanOneRowIdx(jj),:));
            C(moreThanOneRowIdx(jj),:) = 0;
            
            [~,maxIdxTmp] = max(Urot(moreThanOneRowIdx(jj),currCols));
            C(moreThanOneRowIdx(jj),currCols(maxIdxTmp)) = 1;
        end
        
        rowIndices = intersect(find(rowToBlockIndexMap == maxIdx), inactiveIdx);

    end
end
