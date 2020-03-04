%Merge two tree components depending on distances
%[flag, componentDataMerged]=quickshift_breakTreeMerge_fDistanceDefault(cmp1,cmp2,edge1,edge2,rho,strategy)
%Input arguments
%   cmp1,cmp2   structures containing representative distances
%       for the two components to be merged, with fields:
%           actual      actual distance contained in the tree
%           default     default distance assigned to each node
%   edge1,edge2 same as the above, but contain information for only the
%       two root nodes used for merging the tree components
%   rho     ratio to use for the test against the threhsold
%   strategy detemines how distances for the components are inherited by
%       from the individual edges
%Output arguments
%   flag    true if components should be merged according to the given
%       strategy and the distance values. In practice 
%           flag=edge1.actual<rho*threshold;
%       where threshold is decided by the strategy.
%   componentDataMerged     if flag==true, contains the structure analogous
%       to cmp1 and cmp2 but for the merged components
%Optional arguments
%   'relationType',type     chooses how to interpret the values in D and
%       hence how to apply the scale information
%       according to the following table:
%           type    |   values in D
%       ------------+------------------
%       'distance'  |   pairwise distances
%       'similarity'|   pairwise similarities in the [0,1] range
%       Essentially, this directs the sense of the inequality while
%       computing flag. The strategy should be manually chosen to also
%       match the relation type.
function [flag, componentDataMerged]=quickshift_breakTreeMerge_fDistanceDefault(cmp1,cmp2,edge1,edge2,rho,strategy,varargin)

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

% Ver: 09-Mar-2017 14:53:44

% Roberto Tron (tron@bu.edu)

%type of pairwise relation contained in distance fields
relationType='distance';

%parse optional parameters
ivarargin=1;
while ivarargin<=length(varargin)
    switch lower(varargin{ivarargin})
        case 'relationtype'
            ivarargin=ivarargin+1;
            relationType=lower(varargin{ivarargin});
        otherwise
            error(['Argument ' varargin{ivarargin} ' not valid!'])
    end
    ivarargin=ivarargin+1;
end

%computation of the threshold
cmpEmpty=struct('actual',[],'default',[]);
if isempty(cmp1) && isempty(cmp2)
    threshold=min(edge1.default,edge2.default);
    cmp1=cmpEmpty;
    cmp2=cmpEmpty;
else
    if isempty(cmp1)
        cmp1=cmpEmpty;
    end
    if isempty(cmp2)
        cmp2=cmpEmpty;
    end
    %note that the min/max operations on vectors take care of the case where one of the
    %two components is a singleton
    switch lower(strategy)
        case 'maxactual'
            threshold=max([cmp1.actual cmp2.actual]);
        case 'minactual'
            threshold=min([cmp1.actual cmp2.actual]);
        case 'maxdefault'
            threshold=max([cmp1.default cmp2.default]);
        case 'mindefault'
            threshold=min([cmp1.default cmp2.default]);
        case {'maxactualwithmultidefaultcap','maxactualwithmultidefaultmaxcap'}
            threshold=min([max([cmp1.actual cmp2.actual]) cmp1.default cmp2.default]);
        case {'maxactualwithsingledefaultcap','maxactualwithsingledefaultmaxcap'}
            threshold=min([max([cmp1.actual cmp2.actual]) edge1.default]);
        otherwise
            error('Merging threshold strategy not recongnized')
    end
end

%computation of the flag
switch relationType
    case 'distance'
        flag=edge1.actual<rho*threshold;
    case 'similarity'
        flag=edge1.actual>rho*threshold;
    otherwise
        error('Relation type not recognized')
end

%computation of the values for the merged component
if flag
    valsActual=[cmp1.actual,cmp2.actual,edge1.actual];
    switch lower(strategy)
        case {'maxactual','maxactualwithmultidefaultcap','maxactualwithsingledefaultcap',...
                'maxdefault','mindefault'}
            componentDataMerged.actual=max(valsActual);
        case 'minactual'
            componentDataMerged.actual=min(valsActual);
        otherwise
            error('Merging threshold strategy not recongnized.')
    end
    valsDefault=[cmp1.default,cmp2.default,edge1.default];
    switch lower(strategy)
        case {'maxdefault','maxactual','maxactualwithmultidefaultmaxcap','maxactualwithsingledefaultmaxcap'}
            componentDataMerged.default=max(valsDefault);
        case {'mindefault','maxactualwithmultidefaultcap','maxactualwithsingledefaultcap','minactual'}
            componentDataMerged.default=min(valsDefault);
        otherwise
            error('Merging threshold strategy not recongnized.')
    end
else
    componentDataMerged=NaN;
end
