function plotPoints(x,varargin)

if isempty(varargin) || ~isStyleString(varargin{1})
    %a style has not been provided, inject default marker and size

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

    varargin=[{'.','MarkerSize',7} varargin{:}];
elseif styleContainsLine(varargin{1})
    %a style has been provided, but it does not contain a line style
    %so add the default one
    varargin=[['.' varargin{1}] {'MarkerSize',7} varargin{2:end}];
end    
    

d=size(x,1);
switch d
    case 2
        plot(squeeze(x(1,:,:)),squeeze(x(2,:,:)),varargin{:});
    case 3
        plot3(squeeze(x(1,:,:)),squeeze(x(2,:,:)),squeeze(x(3,:,:)),varargin{:});
    otherwise
        error('First dimension of the data must be two or three')
end




