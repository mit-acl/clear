%Break edges in a tree by comparing lengths with a fixed threshold
function treeEdges=quickshift_breakTree(treeDistances,treeEdges,varargin)

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

% Ver: 09-Jul-2018 15:41:34

% Roberto Tron (tron@bu.edu)

threshold=0.01;
%type of pairwise relation contained in D
relationType='distance';

%optional parameters
ivarargin=1;
while ivarargin<=length(varargin)
    switch lower(varargin{ivarargin})
        case 'threshold'
            ivarargin=ivarargin+1;
            threshold=varargin{ivarargin};
        case 'relationtype'
            ivarargin=ivarargin+1;
            relationType=lower(varargin{ivarargin});
        otherwise
            error(['Argument ' varargin{ivarargin} ' not valid!'])
    end
    ivarargin=ivarargin+1;
end

switch relationType
    case 'distance'
        flagRoots=treeDistances>threshold;
    case 'similarity'
        flagRoots=treeDistances<threshold;
    otherwise
        error('Relation type not recognized')
end

idx=1:length(treeDistances);

treeEdges(flagRoots)=idx(flagRoots);
