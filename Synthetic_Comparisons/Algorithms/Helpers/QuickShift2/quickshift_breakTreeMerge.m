%Consider one edge at a time and check if it should be used to merge
%connected components
%function quickshift_breakTreeMerge(treeEdges,treeData,edgesSorted,fMerge)
%Inputs
%   treeEdges   quickshift tree
%   treeData    [1 x NEdges] cell array with data for each edge (e.g.,
%       distances)
%   edgesSorted list of indeces of the edges (points) in the order in which
%       they need to be considered
%   fMerge      function to decide and merge two connected components
%
%The function fMerge should be of the following form:
%   [flag, componentDataMerged]=fMerge(componentData1,componentData2,treeData,treeDataParent)
%where
%   componentData1, componentData2 contain arbitrary data about each
%       component that could be potentially merged. Initially (for
%       components with a single node) they are empty, but are then
%       replaced  with componentDataMerged upon merging
%   treeData,treeDataParent    arbitrary data (e.g. distance) about the
%       start and target endpoints of the candidate edge that would merge
%       the two components
%   flag    true if the function decides that the two components can be
%       merged based on the input data, false otherwise

function [treeEdgesNew,info]=quickshift_breakTreeMerge(treeEdges,treeData,edgesSorted,fMerge,varargin)

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

% Ver: 14-Mar-2017 07:54:50

% Roberto Tron (tron@bu.edu)

flagDebug=false;

%parse optional parameters
ivarargin=1;
while ivarargin<=length(varargin)
    switch lower(varargin{ivarargin})
        case 'debug'
            flagDebug=true;
        otherwise
            error(['Argument ' varargin{ivarargin} ' not valid!'])
    end
    ivarargin=ivarargin+1;
end


NEdges=length(treeEdges);

%Initialization: each point in its own component
%Cell array of vectors that indicate, for each component, which points
%belong to it 
componentIndicator=num2cell(1:NEdges);
%Cell array containing data for each component used to decide merging
componentData=treeData;
%Index of the component for each point
treeComponents=1:NEdges;
%Output tree. Initially, each point is a root
treeEdgesNew=1:NEdges;


%idxEdge contains the candidate edge to add to the output tree
for idxEdge=edgesSorted
    idxParent=treeEdges(idxEdge);
    
    %skip roots
    if idxEdge~=idxParent
        %indeces of components that would be merged by the candidate
        idxComponent1=treeComponents(idxEdge);
        idxComponent2=treeComponents(idxParent);

        %call function to decide merging
        [flagMerge,componentDataMerged]=fMerge(componentData{idxComponent1},componentData{idxComponent2},treeData{idxEdge},treeData{idxParent});

        %if flagMerge=false, don't do anything
        %otherwise merge the components
        if flagMerge
            %add edge
            treeEdgesNew(idxEdge)=treeEdges(idxEdge);

            %Enlarge component with indexComponent1, remove component with indexComponent2
            %manage componentIndicator
            componentIndicator{idxComponent1}=[componentIndicator{idxComponent1} componentIndicator{idxComponent2}];
            componentIndicator{idxComponent2}=[];

            %manage componentData
            componentData{idxComponent1}=componentDataMerged;
            componentData{idxComponent2}=[];

            %manage treeComponents
            treeComponents(componentIndicator{idxComponent1})=idxComponent1;
            
            %in debug mode, check self-consistency of the state after each
            %merge
            if flagDebug && ~quickshift_breakTreeMerge_check(treeComponents,componentData,componentIndicator)
                keyboard
            end
        end
    end
end

if nargout>1
    info.treeComponents=treeComponents;
    info.componentData=componentData;
    info.componentIndicator=componentIndicator;
end
