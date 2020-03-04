%Return indicator variables for roots of the trees
%Optional inputs
%   'indeces'   Returns indeces instead of indicator variables
function flagRoot=quickshift_treeRoots(treeEdges,varargin)

flagIndeces=false;

%optional parameters
ivarargin=1;
while ivarargin<=length(varargin)
    switch lower(varargin{ivarargin})
        case 'indeces'
            flagIndeces=true;
        otherwise
            error(['Argument ' varargin{ivarargin} ' not valid!'])
    end
    ivarargin=ivarargin+1;
end

flagRoot=treeEdges==1:length(treeEdges);

if flagIndeces
    flagRoot=find(flagRoot);
end