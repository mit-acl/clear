%Build the QuickShift tree
%function [treeDistances,treeEdges]=quickshift_tree(P,D,varargin)
%Given the value of the density at each point P ([N x 1] vector) and the
%matrix of pair-wise point distances ([N x N] matrix), generate vectors
%containing the distance to (treeDistances) and index of (treeEdges) of the
%parent in the tree for each point
%Optional arguments
%   'perturbation',e    Add a random perturbation drawn uniformely in the
%       interval [0,e] for breaking ties
%   'membershipPrior',m Prior membership (cluster number) for each point.
%       If provided, the parent of a point cannot come from the same
%       cluster
%   'relationType',type     chooses how to interpret the values in D and
%       hence how to apply the scale information
%       according to the following table:
%           type    |   values in D
%       ------------+------------------
%       'distance'  |   pairwise distances
%       'similarity'|   pairwise similarities in the [0,1] range
%    'relationIndicator',s  the [NPoints x NPoints] matrix s is a logical
%       matrix that indicates if the corresponding entries in the D matrix
%       should be considered or not. Typically, if this option is used both
%       s and D are sparse matrices, allowing significant memory savings.

function [treeDistances,treeEdges]=quickshift_tree(P,D,varargin)

%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.

% Ver: 17-Aug-2017 17:13:27

% Roberto Tron (tron@bu.edu)


N=size(D,1);
%type of pairwise relation contained in D
relationType='distance';

%flag and value for adding random tie-breaking perturbation
flagPerturbation=true;
perturbationEpsilon=1e-6;

%prior membership information to take into account priors
flagMembershipPrior=false;

flagRelationIndicator=false;

%parse optional parameters
ivarargin=1;
while(ivarargin<=length(varargin))
    switch(lower(varargin{ivarargin}))
        case 'noperturbation'
            flagPerturbation=false;
        case 'perturbation'
            ivarargin=ivarargin+1;
            perturbationEpsilon=varargin{ivarargin};
            flagPerturbation=true;
        case 'membershipprior'
            ivarargin=ivarargin+1;
            membershipPrior=varargin{ivarargin};
            flagMembershipPrior=true;
        case 'flagmembershipprior'
            ivarargin=ivarargin+1;
            flagMembershipPrior=varargin{ivarargin};
        case 'relationtype'
            ivarargin=ivarargin+1;
            relationType=lower(varargin{ivarargin});
        case 'relationindicator'
            ivarargin=ivarargin+1;
            relationIndicator=lower(varargin{ivarargin});
            flagRelationIndicator=true;
        otherwise
            error(['Argument ' varargin{ivarargin} ' not valid!'])
    end
    ivarargin=ivarargin+1;
end

switch relationType
    case 'distance'
        relationClosestOperator=@(x) min(x);
    case 'similarity'
        relationClosestOperator=@(x) max(x);
    otherwise
        error('Relation type not recognized')
end

%add small amounts to break ties
if flagPerturbation
    P=P+perturbationEpsilon*rand(size(P)); 
end

treeEdges=zeros(1,N);
treeDistances=zeros(1,N);
for iN=1:N
    flagRelP=P>P(iN);
    if flagRelationIndicator
        flagRelP=and(flagRelP,relationIndicator(:,iN)');
    end
    if flagMembershipPrior
        flagRelP=and(flagRelP,membershipPrior~=membershipPrior(iN));
    end
    if ~any(flagRelP)
        treeDistances(iN)=Inf;
        treeEdges(iN)=iN;
    else
        [minD,idxMinD]=relationClosestOperator(D(flagRelP,iN));
        treeDistances(iN)=minD;
        %go from the index of the minimum in the restricted set to the
        %minimum in the whole set
        treeEdges(iN)=relativeMinPosition(flagRelP,idxMinD);
    end
end

function k=relativeMinPosition(flagRelP,idxMinD)
%k=find(cumsum(flagRelP)==idxMinD,1,'first');
idx=find(flagRelP,idxMinD,'first');
k=idx(end);

