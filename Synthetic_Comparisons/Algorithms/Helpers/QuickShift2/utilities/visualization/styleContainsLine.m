%Returns true if the style string contains a line style
%function flag=styleContainsLine(s)
function flag=styleContainsLine(s)

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

% Ver: 16-Mar-2015 14:19:26

% Roberto Tron (tron@bu.edu)

flag=isempty(regexp(s,'[\*\+sodxvph\-:\.]','once'));
