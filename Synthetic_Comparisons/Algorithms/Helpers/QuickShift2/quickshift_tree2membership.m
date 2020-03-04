%Transform quickshift forest into labels
function membership=quickshift_tree2membership(treeVectorMembership)

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

% Ver: 25-Jul-2016 08:48:19

% Roberto Tron (tron@bu.edu)

%init memberships
membership=zeros(size(treeVectorMembership));

%find roots as those points for which the tree vector points to itself
flagRoots=treeVectorMembership==1:length(treeVectorMembership);

%set labels for roots
membership(flagRoots)=1:sum(flagRoots);

%propagate labels by copying label of target of tree vector pointer into
%the source
while any(membership==0)
    membership=membership(treeVectorMembership);
end
