%function [membershipCorrespondences,info]=quickshift_matching(D,membershipPriors,varargin)
%Arguments
%   D               matrix of distances
%   membershipPrior prior class ("image") membership. Final correspondences
%       will not contain two points from the same prior class ("image").
%Optional arguments
% In the following, dc is the distance to the closest point inside the same
% prior class.
%   'ratioDensity',rho      the bandwidth for the density centered at a point
%       is fixed to rho*dc.
%   'ratioCluster',rho the default distance when breaking the tree
%       using descendants is set to rho*dc.
%   'similarity'    intepret the values in D as similarities in the [0,1]
%       range instead of distances. The options to all subfunctions for
%       computing the scales, densities, tree and for breaking the tree are
%       automatically adjusted to reflect this option.
%   'relationIndicator',s   the [NPoints x NPoints] matrix s is a logical
%       matrix that indicates if the corresponding entries in the D matrix
%       should be considered or not. Typically, if this option is used both
%       s and D are sparse matrices, allowing significant memory savings.

function [membershipCorrespondences,info]=quickshift_matching(D,membershipPrior,varargin)

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

% Ver: 14-Oct-2017 18:27:32

% Roberto Tron (tron@bu.edu)

phi=@(x) exp(-x.^2/2);
ratioDensity=0.25;
ratioInterCluster=0.67;
ratioIntraCluster=1;
thresholdBreakTree=Inf;
mergeStrategy='minDefault';
optsDensity={};
optsScales={};
optsTree={};
optsBreakMerge={};
relationType='distance';
flagComponentDistances=false;

%use fixed scales
flagFixedScales=false;
scalesFixed=NaN;


%parse optional parameters
ivarargin=1;
while ivarargin<=length(varargin)
    switch lower(varargin{ivarargin})
        case 'similarity'
            %set various options to handle similarities instead of
            %distances
            phi=[];
            optsDensity=[optsDensity {'relationType','similarity'}];
            optsScales=[optsScales {'relationType','similarity'}];
            optsTree=[optsTree {'relationType','similarity'}];
            mergeStrategy='maxDefault';
            optsBreakMerge=[optsBreakMerge {'optsDistance',{'relationType','similarity'}}];
            relationType='similarity';
        case 'phi'
            ivarargin=ivarargin+1;
            phi=varargin{ivarargin};
        case 'gaussian'
            phi=@(x) exp(-x.^2/2);
        case 'parabolic'
            phi=@(x) max(0,1-(x/2).^2);
        case 'densitysqrtamplify'
            fAmplify=@(s) sqrt(s);
            optsDensity=[optsDensity {'amplify',fAmplify}];
        case 'densitylogamplify'
            fAmplify=@(s) log(1+s);
            optsDensity=[optsDensity {'amplify',fAmplify}];
        case 'optsdensity'
            ivarargin=ivarargin+1;
            optsDensity=[optsDensity varargin{ivarargin}];
        case 'ratiodensity'
            ivarargin=ivarargin+1;
            ratioDensity=varargin{ivarargin};
        case 'ratiointercluster'
            ivarargin=ivarargin+1;
            ratioInterCluster=varargin{ivarargin};
        case 'ratiointracluster'
            ivarargin=ivarargin+1;
            ratioIntraCluster=varargin{ivarargin};
            warning('Argument ''ratioIntraCluster'' is deprecated. You can use ''ratioInterCluster'' instead')
        case 'mergestrategy'
            ivarargin=ivarargin+1;
            mergeStrategy=varargin{ivarargin};
        case 'threshold'
            ivarargin=ivarargin+1;
            thresholdBreakTree=varargin{ivarargin};
        case 'scales'
            ivarargin=ivarargin+1;
            scalesFixed=varargin{ivarargin};
            flagFixedScales=true;
        case 'usemembershippriorintree'
            optsTree=[optsTree {'membershipPrior',membershipPrior}];
        case 'optstree'
            ivarargin=ivarargin+1;
            optsTree=[optsTree varargin{ivarargin}];
        case 'optsscales'
            ivarargin=ivarargin+1;
            optsScales=[optsScales varargin{ivarargin}];
        case 'getcomponentdistances'
            flagComponentDistances=true;
        case 'relationindicator'
            ivarargin=ivarargin+1;
            relationIndicator=lower(varargin{ivarargin});
            optsScales=[optsScales {'relationIndicator',relationIndicator}];
            optsDensity=[optsDensity {'relationIndicator',relationIndicator}];
            optsTree=[optsTree {'relationIndicator',relationIndicator}];            
        otherwise
            error(['Argument ' varargin{ivarargin} ' not valid!'])
    end
    ivarargin=ivarargin+1;
end

%obtain the scaling factor for the kernel at each point
NPoints=size(D,2);
if ~flagFixedScales
    scales=quickshift_scalesMembershipPrior(D,membershipPrior,optsScales{:});
else
    %doing the assignment this way allows for singleton expansion
    scales=NaN(1,NPoints);
    scales(:)=scalesFixed;  
end

%compute the density at each point
treeDensity=quickshift_density(phi,D,'scales',ratioDensity*scales,optsDensity{:});

if nargout>1
    info.density=treeDensity;
    info.scales=scales;
end

%compute the quickshift tree
[treeDistances,treeEdges]=quickshift_tree(treeDensity,D,optsTree{:});

%remove edges using a fixed threshold
if ~isinf(thresholdBreakTree)
    treeEdgesThreshold=quickshift_breakTree(treeDistances,treeEdges,'threshold',thresholdBreakTree);
else
    treeEdgesThreshold=treeEdges;
end

%remove edges using both distances and priors
fMerge=@(cmpData1,cmpData2,treeData1,treeData2) quickshift_breakTreeMerge_fDistanceDefaultPrior(cmpData1,cmpData2,treeData1,treeData2,...
    ratioInterCluster,mergeStrategy,optsBreakMerge{:});
treeData=num2cell(struct(...
    'distanceWithDefault',num2cell(struct('actual',num2cell(treeDistances),'default',num2cell(ratioIntraCluster*scales))),...
    'prior',num2cell(membershipPrior)));

%sort the edges to consider short edges first
switch relationType
    case 'distance'
        [~,edgesSorted]=sort(treeDistances,'ascend');
    case 'similarity'
        [~,edgesSorted]=sort(treeDistances,'descend');
    otherwise
        error('Relation type not recognized')
end

[treeEdgesClusters,infoTreeMerge]=quickshift_breakTreeMerge(treeEdgesThreshold,treeData,edgesSorted,fMerge);
membershipCorrespondences=mapValues(infoTreeMerge.treeComponents);

%if requested, extract distance information from the component to which
%each point belongs to
if flagComponentDistances && nargout>1
    %create array of component data for each point
    componentData=[infoTreeMerge.componentData{infoTreeMerge.treeComponents}];
    info.componentDistances.actual=arrayfun(@(x) x.distanceWithDefault.actual, componentData);
    info.componentDistances.default=arrayfun(@(x) x.distanceWithDefault.default, componentData);
end
    
% %remove edges using adaptive threshold
% distancesDefault=ratioIntraCluster*scales;
% treeEdgesClusters=quickshift_breakTreeDescendentsOrdered(treeThreshold,treeEdges,treeDensity,...
%     'ratio',ratioInterCluster,...
%     'distancesDefault',distancesDefault);
% 
if nargout>1
    info.infoTreeMerge=infoTreeMerge;
    info.treeEdges=treeEdges;
    info.treeEdgesClusters=treeEdgesClusters;
    info.treeDistances=treeDistances;
    info.phi=phi;
    info.optsDensity=optsDensity;
end
% 
% %break tree using prior membership information
% if flagMembershipPrior
%     [membershipCorrespondences,treeEdgesPrior,clustersIndicatorsPrior]=...
%         quickshift_breakTreePrior(treeDistances,treeEdges,membershipPrior);
%     if nargout>1
%         info.clustersIndicatorsPrior=clustersIndicatorsPrior;
%         info.treeEdgesPrior=treeEdgesPrior;
%     end
% else
%     membershipCorrespondences=quickshift_tree2membership(treeEdgesClusters);
% end
% 
% 
