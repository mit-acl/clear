%Break a tree based on ratio of distances of edge and descendents
%function treeEdges=quickshift_breakTreeDescendentsOrdered(treeDistances,treeEdges,treeDensity,varargin)
%For each edge, compute the maximum distance in all descendent edges. If
%the distance associated to the edge is larger than some ratio times the
%extremum (min or max) descendents' distance, then break the edge and make a new root.
%This encourages the formation of clusters that are compact with respect their
%distance to neighboring clusters.
%Uses the unique ordering of the nodes given by the density values to break
%the tree in a bottom-up manner.
%Input Arguments
%   vDist   vector of distances associated to each edge
%   vTree   index of the ancestor for each datapoint
%Optional Arguments
%   'ratio',r           ratio that needs to be exceeded in order to cut an
%       edge (default: 1)
%   'distancesDefault',v    vector of default distances that need to be used
%       for nodes that do not have descendents (default:
%       vDistDefault=vDist). Intuitively, it can be used to constrain the
%       minimum cluster size (parent/child pairs with distance less than
%       ratio*vDistDefault are always in the same cluster).
function [treeEdges,descendents,treeDistancesMax]=quickshift_breakTreeDescendentsOrdered(treeDistances,treeEdges,treeDensity,varargin)

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

% Ver: 31-Oct-2016 20:48:31

% Roberto Tron (tron@bu.edu)

ratio=1;
treeDistancesDefault=treeDistances;
flagDebugInfo=false;
flagDebugShowTree=false;
flagFixedLeaves=false;

%optional parameters
ivarargin=1;
while(ivarargin<=length(varargin))
    switch(lower(varargin{ivarargin}))
        case 'ratio'
            ivarargin=ivarargin+1;
            ratio=varargin{ivarargin};
        case 'distancesdefault'
            ivarargin=ivarargin+1;
            treeDistancesDefault=varargin{ivarargin};
            if numel(treeDistancesDefault)==1
                treeDistancesDefault=treeDistancesDefault*ones(size(treeDistances));
            end
        case 'debuginfo'
            flagDebugInfo=true;
        case 'debugshowtree'
            ivarargin=ivarargin+1;
            X=varargin{ivarargin};
            flagDebugShowTree=true;
        otherwise
            error(['Argument ' varargin{ivarargin} ' not valid!'])
    end
    ivarargin=ivarargin+1;
end

NPoints=length(treeEdges);

[~,allIdxSorted]=sort(treeDensity,'ascend');
if flagFixedLeaves
    flagLeaf=quickshift_findLeaves(treeEdges);
else
    childrenCount=zeros(1,NPoints);
    for idxEdge=1:NPoints
        idxEdgeNext=treeEdges(idxEdge);
        if idxEdgeNext~=idxEdge
            childrenCount(idxEdgeNext)=childrenCount(idxEdgeNext)+1;
        end
    end
end
descendents=num2cell(1:NPoints);
treeDistancesMax=zeros(1,NPoints);

for idxEdge=allIdxSorted
    if flagFixedLeaves
        flagLeafEdge=flagLeaf(idxEdge);
    else
        flagLeafEdge=(childrenCount(idxEdge)==0);
    end
    if flagDebugInfo
        fprintf('Idx:%d IsLeaf:%d vDist:%.4f vMax:%.4f vDistDefault:%.4f',...
            [idxEdge flagLeafEdge treeDistances(idxEdge) treeDistancesMax(idxEdge) treeDistancesDefault(idxEdge)])
        if ~flagFixedLeaves
            fprintf('nb. children:%d',childrenCount(idxEdge));
        end
        fprintf('\n')
    end
    
    if flagDebugShowTree
        quickshift_plotTree(X,treeEdges)
        hold on
        plotPoints(X(:,[idxEdge treeEdges(idxEdge)]),'ro')
        hold off
    end
    if ( flagLeafEdge && treeDistances(idxEdge)>ratio*treeDistancesDefault(idxEdge))...
            || (~flagLeafEdge && treeDistances(idxEdge)>ratio*treeDistancesMax(idxEdge))
        %remove edge
        if flagDebugInfo
            fprintf('Action: cut\n')
        end
        if ~flagFixedLeaves
            idxEdgeNext=treeEdges(idxEdge);
            childrenCount(idxEdgeNext)=childrenCount(idxEdgeNext)-1;
        end
        treeEdges(idxEdge)=idxEdge;
    else
        %update descendents and maximum distance recursively
        if flagDebugInfo
            fprintf('Action: keep\n')
        end
        idxEdgeNext=treeEdges(idxEdge);
        descendents{idxEdgeNext}=...
            [descendents{idxEdgeNext} descendents{idxEdge}];
        if flagLeafEdge
            newDist=max([treeDistancesMax(idxEdge) treeDistances(idxEdge) treeDistancesDefault(idxEdge)]);
        else
            newDist=max([treeDistancesMax(idxEdge) treeDistances(idxEdge)]);
        end            
        treeDistancesMax(idxEdgeNext)=newDist;
            
    end
end

