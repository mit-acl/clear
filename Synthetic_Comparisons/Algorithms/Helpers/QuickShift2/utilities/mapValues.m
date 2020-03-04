%function vMapped=mapValues(v,m,varargin)
%Maps values in v from m(:,1) to m(:,2)
%If the 
%If m has only one column, the second is filled to be (1:size(m,1))'
%If m is omitted or empty, the first column is filled with unique(v), and
%the second as the above.
%Optional inputs
%   'actionMapped',s    Determines what to do for values in v are not found in m(:,1)
%       'none'          Values are left unchanged (default)
%       'remove'        Values are removed from vMapped

function vMapped=mapValues(v,m1,varargin)

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

% Ver: 17-Mar-2015 16:57:18

% Roberto Tron (tron@bu.edu)

actionUnmapped='none';

%optional parameters
ivarargin=1;
while ivarargin<=length(varargin)
    switch lower(varargin{ivarargin})
        case 'actionunmapped'
            ivarargin=ivarargin+1;
            actionUnmapped=lower(varargin{ivarargin});
        otherwise
            disp(varargin{ivarargin})
            error('Argument not valid!')
    end
    ivarargin=ivarargin+1;
end

if ~exist('m1','var') || isempty(m1)
    m1=shiftdim(unique(v));
end

if size(m1,2)==1
    nm=size(m1);
    m1(:,2)=(1:nm)';
end

vMapped=v;

switch actionUnmapped
    case 'none'
        %nothing to do
    case 'remove'
        vMapped(~ismember(vMapped,m1(:,1)))=[];
    otherwise
        error('actionUnmapped not recognized')
end

for im=1:size(m1,1)
    vMapped(v==m1(im,1))=m1(im,2);
end

