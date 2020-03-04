%Plot a quickshift tree
function quickshift_plotTree(X,treeVectorMembership,varargin)

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

% Ver: 09-Jul-2018 16:11:44

% Roberto Tron (tron@bu.edu)

flagArrows=true;

%optional parameters
ivarargin=1;
while ivarargin<=length(varargin)
    if isstring(varargin{ivarargin})
        switch lower(varargin{ivarargin})
            case 'noarrows'
                flagArrows=false;
                varargin(ivarargin)=[];
                ivarargin=ivarargin-1;
            otherwise
        end
    end
    ivarargin=ivarargin+1;
end


XTo=X(:,treeVectorMembership);
%XDiff=XTo-X;
switch size(X,1)
    case 2
        if flagArrows
            quiver(X(1,:),X(2,:),XTo(1,:)-X(1,:),XTo(2,:)-X(2,:),0,'k-',varargin{:})
        else
            plot([X(1,:);XTo(1,:)],[X(2,:); XTo(2,:)],'k-',varargin{:})
        end
    case 3
        if flagArrows
            quiver3(X(1,:),X(2,:),X(3,:),XTo(1,:)-X(1,:),XTo(2,:)-X(2,:),XTo(3,:)-X(3,:),0,'k-',varargin{:})
        else
            plot3([X(1,:);XTo(1,:)],[X(2,:); XTo(2,:)],[X(3,:); XTo(3,:)],'k-',varargin{:})
        end
end
