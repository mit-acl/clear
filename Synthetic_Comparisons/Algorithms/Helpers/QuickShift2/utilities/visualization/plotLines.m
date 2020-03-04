%Plot lines given start and end points
%function plotLines(xStart,xEnd,varargin)
%This is essentially a smart version of plot which does not require
%separating and assembling the various coordinates of the points
function plotLines(xStart,xEnd,varargin)

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

% Ver: 16-Sep-2017 12:38:34

% Roberto Tron (tron@bu.edu)


if isempty(varargin) || ~isStyleString(varargin{1})
    %a style has not been provided, inject default marker and size
    varargin=[{'-'} varargin{:}];
elseif styleContainsLine(varargin{1})
    %a style has been provided, but it does not contain a line style
    %so add the default one
    varargin=[{['-' varargin{1}]} varargin{2:end}];
end    

%number of input start/end points
NXStart=size(xStart,2);
NXEnd=size(xEnd,2);

%return if either is empty
if NXStart==0 || NXEnd==0
    return
end

%repeat points if start or end is a singleton
if NXStart==1 && NXEnd>1
    xStart=repmat(xStart,1,NXEnd);
    NXStart=NXEnd;
end
if NXEnd==1 && NXStart>1
    xEnd=repmat(xEnd,1,NXStart);
    NXEnd=NXStart;
end

if NXEnd~=NXStart
    error('The number of start/end points must match, or one of them must be one.')
end

sz=size(xStart);
d=sz(1);
xData=zeros(2,prod(sz(2:end)),d);
for id=1:d
    xData(:,:,id)=[squeeze(xStart(id,:,:));squeeze(xEnd(id,:,:))];
end
switch d
    case 2
        plot(xData(:,:,1),xData(:,:,2),varargin{:});
    case 3
        plot3(xData(:,:,1),xData(:,:,2),xData(:,:,3),varargin{:});
    otherwise
        error('First dimension of the data must be two or three')
end
