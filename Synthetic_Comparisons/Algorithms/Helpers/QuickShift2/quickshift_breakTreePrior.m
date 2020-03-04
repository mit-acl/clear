%Break a tree based on prior membership information
%function [membershipCluster,treeEdges,clustersIndicators]=quickshift_breakTreePrior(treeDistances,treeEdges,membershipPrior)
function [membershipCluster,treeEdges,clustersIndicators]=quickshift_breakTreePrior(treeDistances,treeEdges,membershipPrior)

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

% Ver: 02-Sep-2016 17:57:38

% Roberto Tron (tron@bu.edu)

NPoints=length(treeDistances);

%vector with cluster number for each point
membershipCluster=1:NPoints;
%matrix with indicator of memberships for each cluster
clustersIndicators=sparse(1:NPoints,membershipPrior,ones(1,NPoints));

idxNotRoot=find(not(treeEdges==1:NPoints));
[~,idxIdxSortDist]=sort(treeDistances(idxNotRoot));
idxSortDist=idxNotRoot(idxIdxSortDist);

for iIdx=1:length(idxSortDist)
    %index of the candidate edge
    idx=idxSortDist(iIdx);
    
    %indeces of the two clusters that should be merged
    k1=membershipCluster(idx);
    k2=membershipCluster(treeEdges(idx));
    
    %indicator vector for the two clusters after merging
    clusterIndicatorMerged=clustersIndicators(k1,:)+clustersIndicators(k2,:);
    
    if any(clusterIndicatorMerged>1)
        %edge would create conflict, remove it
        treeEdges(idx)=idx;
    else
        %merge the clusters:
        %update cluster k1
        clustersIndicators(k1,:)=clusterIndicatorMerged;
        
        %clear cluster k2
        clustersIndicators(k2,find(clustersIndicators(k2,:)))=0;
        
        %move points from k2 to k1
        membershipCluster(membershipCluster==k2)=k1;
    end
        
end

