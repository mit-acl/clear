%Given a distance matrix, divide the points in clusters
function [membershipCluster,info]=quickshift_cluster(D,varargin)

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

% Ver: 09-Jul-2018 16:10:07

% Roberto Tron (tron@bu.edu)

phi=@(x) exp(-x.^2/2);
methodBreakTree='threshold';
optsBreakTree={};
optsTree={};
optsDensity={};
flagMembershipPrior=false;
Threshold=0.2;

%optional parameters
ivarargin=1;
while(ivarargin<=length(varargin))
    switch(lower(varargin{ivarargin}))
        case 'phi'
            ivarargin=ivarargin+1;
            phi=varargin{ivarargin};
        case 'optsDensity'
            ivarargin=ivarargin+1;
            optsDensity=varargin{ivarargin};
        case 'gaussian'
            ivarargin=ivarargin+1;
            phi=@(x) exp(-x.^2/(2*varargin{ivarargin}^2));
        case 'optsbreaktree'
            ivarargin=ivarargin+1;
            optsBreakTree=[optsBreakTree varargin{ivarargin}];
            %optsBreakTree={methodBreakTree varargin{ivarargin}};
        case 'optstree'
            ivarargin=ivarargin+1;
            optsTree=[optsTree varargin{ivarargin}];
        case 'methodbreaktree'
            ivarargin=ivarargin+1;
            methodBreakTree=varargin{ivarargin};
        case 'membershipprior'
            ivarargin=ivarargin+1;
            membershipPrior=varargin{ivarargin};
            flagMembershipPrior=true;
        otherwise
            error(['Argument ' varargin{ivarargin} ' not valid!'])
    end
    ivarargin=ivarargin+1;
end

if isempty(optsBreakTree)
    optsBreakTree={methodBreakTree Threshold};
end

%compute the density at each point
treeDensity=quickshift_density(phi,D,optsDensity{:});
if nargout>1
    info.density=treeDensity;
end

%compute the quickshift tree
[treeDistances,treeEdges]=quickshift_tree(treeDensity,D,optsTree{:});

%break tree using distances
switch lower(methodBreakTree)
    case 'threshold'
        treeEdgesClusters=quickshift_breakTree(treeDistances,treeEdges,optsBreakTree{:});
    case 'descendents'
        %treeEdgesClusters=quickshift_breakTreeDescendents(treeDistances,treeEdges,optsBreakTree{:});
        treeEdgesClusters=quickshift_breakTreeDescendentsOrdered(treeDistances,treeEdges,treeDensity,optsBreakTree{:});
    case 'descendentstopdown'
        treeEdgesClusters=quickshift_breakTreeDescendents(treeDistances,treeEdges,optsBreakTree{:});
        
end
if nargout>1
    info.treeEdges=treeEdges;
    info.treeEdgesClusters=treeEdgesClusters;
    info.treeDistances=treeDistances;
end

%break tree using prior membership information
if flagMembershipPrior
    [membershipCluster,treeEdgesPrior,clustersIndicatorsPrior]=...
        quickshift_breakTreePrior(treeDistances,treeEdges,membershipPrior);
    if nargout>1
        info.clustersIndicatorsPrior=clustersIndicatorsPrior;
        info.treeEdgesPrior=treeEdgesPrior;
    end
else
    membershipCluster=quickshift_tree2membership(treeEdgesClusters);
end


