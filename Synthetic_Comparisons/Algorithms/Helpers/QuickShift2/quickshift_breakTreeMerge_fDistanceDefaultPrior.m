%Verify whether to combine or not two clusters using both edge lengths and membership prior criteria
%Used as argument to quickshift_breakTreeMerge

function [flag, cmpMerged]=quickshift_breakTreeMerge_fDistanceDefaultPrior(cmp1,cmp2,edge1,edge2,rho,strategy,varargin)

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

% Ver: 09-Jul-2018 15:51:42

% Roberto Tron (tron@bu.edu)

optsDistance={};

%parse optional parameters
ivarargin=1;
while(ivarargin<=length(varargin))
    switch(lower(varargin{ivarargin}))
        case 'optsdistance'
            ivarargin=ivarargin+1;
            optsDistance=[optsDistance varargin{ivarargin}];
        otherwise
            error(['Argument ' varargin{ivarargin} ' not valid!'])
    end
    ivarargin=ivarargin+1;
end

%break arguments for cmp1 and cmp2 data
if isempty(cmp1)
    cmpDist1=[];
    cmpPrior1=[];
else
    cmpDist1=cmp1.distanceWithDefault;
    cmpPrior1=cmp1.prior;
end
if isempty(cmp2)
    cmpDist2=[];
    cmpPrior2=[];
else
    cmpDist2=cmp2.distanceWithDefault;
    cmpPrior2=cmp2.prior;
end

%break arguments for edge1 and edge2 data
edgeDist1=edge1.distanceWithDefault;
edgePrior1=edge1.prior;

edgeDist2=edge2.distanceWithDefault;
edgePrior2=edge2.prior;

%call the two merging strategies' checks
[flagDist,cmpMergedDist]=quickshift_breakTreeMerge_fDistanceDefault(cmpDist1,cmpDist2,edgeDist1,edgeDist2,rho,strategy,optsDistance{:});
[flagPrior,cmpMergedPrior]=quickshift_breakTreeMerge_fPrior(cmpPrior1,cmpPrior2,edgePrior1,edgePrior2);

%combine the results
flag=flagDist & flagPrior;
cmpMerged=struct('distanceWithDefault',cmpMergedDist,'prior',cmpMergedPrior);

