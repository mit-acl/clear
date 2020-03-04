%% Wrapper for QuickMatch algorithm (by Roberto Tron) 
%
% Inputs:
%
%           - TT:       Initial permutations (aka. correspondences or score matrices)
%           - numSmp:   Number of observations for each agent
%           - numObj:   Number of objects in the universe
%           - numAgt:   Number of agents (aka. frames or observations)
%           - adj:      Adjacency matrix
%
%
% Outputs:
%
%           - TT_out:   Consistent permutations
%
%
function TT_out = QuickMatch(TT, numSmp, varargin)


% Paramters
numObj = 0; 

ivarargin = 1;
while ivarargin <= length(varargin)
    switch lower(varargin{ivarargin})
        case 'numobj'
            ivarargin = ivarargin+1;
            numObj = varargin{ivarargin};
        otherwise
            fprintf('Unknown option ''%s'' is ignored!',varargin{ivarargin});
    end
    ivarargin = ivarargin+1;
end

numSmpSum = sum(numSmp); % Total number of observations
idxSum = [0, cumsum(numSmp)]; % Cumulative index


%%

% Pairwise distance matrix from input
D = TT;
% D(TT==1) = 0;
% D(TT==0) = Inf;

% Index of agents
% membershipPrior = (1:size(TT,1));
membershipPrior = zeros(1,size(TT,1));
for i = 1 : length(numSmp)
    membershipPrior(idxSum(i)+1:idxSum(i+1)) = i;
end

% Common parameters to all tests
paramsMatchingCommon = {'similarity','scales',1};
% paramsMatchingCommon={'gaussian',...
%     'ratioDensity',0.25,...
%     'ratioInterCluster',0.67,...
%     'threshold',Inf,...
%     'densityLogAmplify'};

% No additional criteria for matching
paramsMatching={};

% % Use prior membership during matching
% paramsMatching={'useMembershipPriorInTree'};

% % Use distances with neighbors already in same cluster to compute
% %the scale of each edge
% paramsMatching={'optsScales',{'proportionalInterNeighbor',4},...
%     'ratioInterCluster',0.5};

% Clustering using QuickMatch algorithm
[membershipMatches,info] = quickshift_matching(D,membershipPrior,...
    paramsMatchingCommon{:},...
    paramsMatching{:});


% Generate aggregate permutation matrix
TT_out = zeros(size(TT));
idxMax = max(membershipMatches);


for i = 1 : idxMax
    idx = (membershipMatches == i);
    TT_out(idx, idx) = ones(nnz(idx));
end




