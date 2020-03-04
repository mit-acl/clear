%Break a tree based on ratio of distances of edge and descendents
%function treeEdges=quickshift_breakTreeDescendents(treeDistances,treeEdges,varargin)
%For each edge, compute the maximum distance in all descendent edges. If
%the distance associated to the edge is larger than some ratio times the
%extremum (min or max) descendents' distance, then break the edge and make a new root.
%This encourages the formation of clusters that are compact with respect their
%distance to neighboring clusters.
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
function treeEdges=quickshift_breakTreeDescendents(treeDistances,treeEdges,varargin)

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

% Ver: 02-Sep-2016 17:30:33

% Roberto Tron (tron@bu.edu)

ratio=1;
treeDistancesDefault=treeDistances;
flagDebugInfo=false;

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
        otherwise
            error(['Argument ' varargin{ivarargin} ' not valid!'])
    end
    ivarargin=ivarargin+1;
end

flagRunning=true;
%continue until we do not find any edge that needs to be removed
while flagRunning
    descendents=quickshift_treeDescendents(treeEdges);
    vMaxDist=maxDistDescendents(descendents,treeDistances,treeDistancesDefault);
    if flagDebugInfo
        fprintf('---\n')
        disp([quickshift_treeDescendentsCount(descendents);vMaxDist;treeDistances])
    end
    %find edges that are longer than those below them
    idxRemove=find(treeDistances>ratio*vMaxDist);
    if isempty(idxRemove)
        flagRunning=false;
    else
        %remove these edges
        treeEdges(idxRemove)=idxRemove;
        treeDistances(idxRemove)=0;
    end
end

%Compute the maximum distance across descendents
function vMaxDist=maxDistDescendents(descendents,vDist,vDistDefault)
NDist=length(vDist);
vMaxDist=zeros(1,NDist);
cnt=quickshift_treeDescendentsCount(descendents);
vDist(cnt==0)=vDistDefault(cnt==0);
for iDist=1:NDist
    d=descendents{iDist};
    if isempty(d)
        vMaxDist(iDist)=vDist(iDist);
    else
        vMaxDist(iDist)=max([0 vDist(d)]);
    end
end
