%Find all the descendents of each point in a tree
function descendents=quickshift_treeDescendents(vTree)

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

% Ver: 09-Jul-2018 16:12:46

% Roberto Tron (tron@bu.edu)

NTree=length(vTree);
descendents=cell(1,NTree);
flagContinue=true;
while flagContinue
    cntPre=quickshift_treeDescendentsCount(descendents);
    descendents=appendDescendents(descendents,vTree);
    cntPost=quickshift_treeDescendentsCount(descendents);
    flagContinue=any(cntPost-cntPre);
end

%for each root, remove itself from the descendents
for idxRoot=find(vTree==1:NTree)
    descendents{idxRoot}=setdiff(descendents{idxRoot},idxRoot);
end

function descendents=appendDescendents(descendents,vTree)
Nd=length(descendents);
for id=1:Nd
    descendents{vTree(id)}=shiftdim(union(descendents{vTree(id)},[descendents{id};id]));
end
