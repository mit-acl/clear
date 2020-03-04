%Evaluates the value of the density from the kernel and distances
%function treeDensity=quickshift_density(phi,data,varargin)
%Input arguments
%   phi     function handle that computes the kernel at each point. E.g.,
%       phi=@(x) exp(-x.^2/2)
%   data    if the 'lowMemory' option is not passed, data is D, a NPoints x
%       NPoints matrix of inter-point distances. If the 'lowMemory' option
%       is passed, data must be a [dim x NPoints] array with the data
%       vectors
%Optional arguments
%   'scales',s      The bandwidth to use for the kernel at each point. In
%       practice, the kernel is evaluated using phi(x/s)
%   'amplify',f     The output of the kernel is rescaled as phi(x/s)*f(s).
%       For instance, f=@(s) s gives a scaling proportional to the
%       scale
%   'kernelSupportRadius',r     Specify a radius for the suppor of the
%       kernel. The kernel is never computed for points outside this
%       radius.
%   'lowmemory'     Enable low-memory mode, where the computation of the
%       distance is done inside this function and the density is computed
%       by chunks
%   'relationType',type     chooses how to interpret the values in D and
%       hence how to apply the scale information
%       according to the following table:
%           type    |   values in D
%       ------------+------------------
%       'distance'  |   pairwise distances
%       'similarity'|   pairwise similarities in the [0,1] range
%    'relationIndicator',s  the [NPoints x NPoints] matrix s is a logical
%       matrix that indicates if the corresponding entries in the D matrix
%       should be considered or not. Typically, if this option is used both
%       s and D are sparse matrices, allowing significant memory savings.
%Note: The function works also for a non-square distance matrix D. In this
%case the rows of D are points contributing to the density, while columns
%are the points at which the density is evaluated
function treeDensity=quickshift_density(phi,data,varargin)

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

% Ver: 14-Mar-2017 17:06:11

% Roberto Tron (tron@bu.edu)

flagScales=false;
flagAmplify=false;
kernelSupportRadius=Inf;
flagLowMemory=false;
flagRecursive=false;    %recursive call, ignore low memory flag
numelDataChunk=1e8;
relationType='distance';
flagRelationIndicator=false;

%parse optional parameters
ivarargin=1;
while(ivarargin<=length(varargin))
    switch(lower(varargin{ivarargin}))
        case 'scales'
            ivarargin=ivarargin+1;
            scales=varargin{ivarargin};
            flagScales=true;
        case 'amplify'
            ivarargin=ivarargin+1;
            fAmplify=varargin{ivarargin};
            flagAmplify=true;
        case 'kernelsupportradius'
            ivarargin=ivarargin+1;
            kernelSupportRadius=varargin{ivarargin};
        case 'lowmemory'
            flagLowMemory=true;
        case 'numeldatachunk'
            ivarargin=ivarargin+1;
            numelDataChunk=varargin{ivarargin};
        case 'recursive'
            flagRecursive=true;
        case 'debugdistances'
            ivarargin=ivarargin+1;
            DDebug=varargin{ivarargin};
        case 'relationtype'
            ivarargin=ivarargin+1;
            relationType=lower(varargin{ivarargin});
        case 'relationindicator'
            ivarargin=ivarargin+1;
            relationIndicator=lower(varargin{ivarargin});
            flagRelationIndicator=true;
        otherwise
            error(['Argument ' varargin{ivarargin} ' not valid!'])
    end
    ivarargin=ivarargin+1;
end

if flagAmplify && ~flagScales
    error('The ''amplify'' option requires the ''scales'' option')
end

%compute amplification factors, if necessary
if flagAmplify
    f=arrayfun(fAmplify,scales);
end

if ~flagLowMemory || flagRecursive
    D=data;
    if flagScales
        switch relationType
            case 'distance'
                %apply domain scaling
                D=bsxfun(@rdivide,D,scales');
            case 'similarity'
                %apply piece-wise sharpen
                D=piecewiseSharpenSimilarity(D,scales');
            otherwise
                error('Relation type not recognized')
        end
    end

    if isempty(phi)
        p=D;
    else
        if flagRelationIndicator
            %build p using the same sparsity pattern as relationIndicator
            [m,n]=size(D);
            [i,j]=find(relationIndicator);
            v=D(sub2ind([m,n],i,j));
            p=sparse(i,j,phi(v),m,n);
        else
            if isinf(kernelSupportRadius)
                p=phi(D);
            else
                p=zeros(size(D));
                flag=D<kernelSupportRadius;
                p(flag)=phi(D(flag));
            end
        end
    end
    if flagAmplify
        p=bsxfun(@times,p,shiftdim(f));
    end
    treeDensity=full(sum(p));
else
    if ~strcmpi(relationType,'distance')
        error('Low memory mode is available only for distance relations')
    end
    %divide data into chunks
    NData=size(data,2);
    %compute how many data points in each chunk
    %note that the use of ceil means that NDataChunck>=1
    NDataChunk=ceil(numelDataChunk/NData);
    treeDensity=NaN(1,NData);
    for iData=1:NDataChunk:NData
        idxDataChunk=iData:min(iData+NDataChunk-1,NData);
        D=sqrt(euclideanDistMatrix(data(:,idxDataChunk),data))';
        treeDensity(idxDataChunk)=quickshift_density(phi,D,varargin{:},'recursive');
    end
    
end
    

