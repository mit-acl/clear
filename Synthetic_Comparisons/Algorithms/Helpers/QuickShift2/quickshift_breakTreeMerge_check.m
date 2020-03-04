%Function to check a couple of self-consistency properties for the output
%of quickshift_breakTreeMerge
function flag=quickshift_breakTreeMerge_check(treeComponents,componentData,componentIndicator)

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

% Ver: 09-Jul-2018 15:42:36

% Roberto Tron (tron@bu.edu)

flag=true;
if any(cellfun(@isempty,{componentData{treeComponents}}))
    disp('Checking that treeComponents points to non-empty componentData')
    disp('Error: invalid references to empty componentData')
    flag=false;
end

if ~all(cellfun(@isempty,componentData)==cellfun(@isempty,componentIndicator))
    disp('Checking that componentData and componentIndicator have same support')
    disp('Error: different supports (the two structures are not consistent)')
    flag=false;
end
