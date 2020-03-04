% This function is part of the NmfSync algorithm for the synchronisation of
% partial permutation matrices, as described in [1]. When you use this
% code, you are required to cite [1].
% 
% [1] Synchronisation of Partial Multi-Matchings via Non-negative
% Factorisations F. Bernard, J. Thunberg, J. Goncalves, C. Theobalt.
% Pattern Recognition. 2019
%
% This function implements an interface to the Auction algorithm for
% solving partial linear assignment problems in a block matrix. When using
% this implementation in your work, in addition to [1,2] you are required to
% cite [3].
%
% [2] Bertsekas, D.P. 1998. Network Optimization: Continuous and Discrete
% Models. Athena Scientific.
%
% [3] Bernard, F., Vlassis, N., Gemmar, P., Husch, A., Thunberg, J.,
% Goncalves, J. and Hertel, F. 2016. Fast correspondences for
% statistical shape models of brain structures. SPIE Medical Imaging,
% San Diego, CA, 2016.
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
function Pproj = projectOntoPartialPermBlockwise(Pin, rowDims, colDims, approxFlag, ...
        epsilon, epsilonDecreaseFactor)
    
    if ( ~exist('approxFlag', 'var') )
        approxFlag = 0;
    end
    if ( ~exist('epsilon', 'var') )
        epsilon = [];
    end
    if ( ~exist('epsilonDecreaseFactor', 'var') )
        epsilonDecreaseFactor = [];
    end
    if (~exist('rowDims', 'var') || isempty(rowDims))
        rowDims = size(Pin,1);
    end
    if (~exist('colDims', 'var') || isempty(colDims) )
        colDims = size(Pin,2);
    end
    
    assert(size(Pin,1)==sum(rowDims)&size(Pin,2)==sum(colDims));
    
    smallestElement = 1e6;
    
    Pin = sparse(Pin);
    Pproj = sparse(sum(rowDims), sum(colDims));
    for c=1:numel(colDims)
        colIdx = (sum(colDims(1:c-1)) + 1):sum(colDims(1:c));
        for r=1:numel(rowDims)
            rowIdx = (sum(rowDims(1:r-1)) + 1):sum(rowDims(1:r));
            
            currBlock = Pin(rowIdx,colIdx);
            
            if ( approxFlag )
                currP = greedyLap(currBlock);
            else
                currBlock = currBlock - min(currBlock(:)) + sparse(1);
                currBlock = currBlock*smallestElement;
                
                % introduce dummy elements if matrix is not square
                sizeDiff = size(currBlock,1) - size(currBlock,2);
                
                if ( sizeDiff < 0 )
                    % add abs(sizeDiff) rows
                    newBlock = ((smallestElement-1)/abs(sizeDiff))*...
                        rand(abs(sizeDiff), size(currBlock,2));
                    % using random numbers in [0,1] improves convergence speed
                    
                    currBlock = [currBlock; newBlock];
                elseif ( sizeDiff > 0 )
                    % add sizeDiff cols
                    newBlock = ((smallestElement-1)/sizeDiff)*...
                        rand(size(currBlock,1), sizeDiff);
                    
                    currBlock = [currBlock, newBlock];
                end
                
                [~,currP] = sparseAssignmentProblemAuctionAlgorithm(...
                    currBlock, epsilon, epsilonDecreaseFactor, 0, 0);
            end
            
            Pproj(rowIdx,colIdx) = currP(1:rowDims(r), 1:colDims(c));
        end
    end
end