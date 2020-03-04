%Plot scales as circles centered at the corresponding points
function quickshift_plotScales(X,scales,varargin)

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

% Ver: 09-Jul-2018 16:10:58

% Roberto Tron (tron@bu.edu)

NPoints=size(X,2);
for iPoint=1:NPoints
    plotCircle(X(1,iPoint),X(2,iPoint),scales(iPoint),varargin{:});
end
