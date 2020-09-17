%% Match feature descriptors using Lowe's ration test
%
% Inputs:
%           - imgDes:       SIFT descriptors    
%           - numSmp:       Number of features in each image
%           - numAgt:       Number of images
%
% Outputs:
%           - Pb:           Aggregate association matrix
%           - Xb:           Associations saved in a cell
%
% Options:
%           - ratio:        Ratio for outlier rejection in Lowe's method
%
%
function [Pb, Xb] = Match_Features(imgDes, numSmp, numAgt, varargin)
% Preallocate paramters
ratio = 1.5; 
feedback = false; % Dispay execution details, can be 'false' or 'true' 

ivarargin = 1;
while ivarargin <= length(varargin)
    switch lower(varargin{ivarargin})
        case 'ratio'
            ivarargin = ivarargin+1;
            ratio = varargin{ivarargin};       
        case 'feedback'
            ivarargin = ivarargin+1;
            feedback = varargin{ivarargin};  
        otherwise
            fprintf('Unknown option ''%s'' is ignored!',varargin{ivarargin});
    end
    ivarargin = ivarargin+1;
end


%%
numSmpSum = sum(numSmp); % Total number of observations
idxSum = [0, cumsum(numSmp)]; % Cumulative index

Xb = cell(numAgt, numAgt);
Pb = eye(numSmpSum);  % Baseline association matrix 

% Reciprocal matches
for i = 1 : numAgt-1
    idxi = [idxSum(i)+1 : idxSum(i+1)];
    for j = i+1 : numAgt 
        idxj = [idxSum(j)+1 : idxSum(j+1)];
        
        % Feature point descriptors 
        desi = imgDes{i};
        desj = imgDes{j};
        
        % Matching
        if feedback, fprintf('Matching...\n'); end
        [matches, scores] = vl_ubcmatch(desi,desj,ratio);
        
        Xij = zeros(numSmp(i), numSmp(j));
        for k = 1 : size(matches,2)
            Xij(matches(1,k), matches(2,k)) = 1;
        end        
        
        % Save match data
        Xb{i,j} = Xij;
        Xb{j,i} = Xij';
        Pb(idxi, idxj) = Xij;
        Pb(idxj, idxi) = Xij';
                
        if feedback, fprintf('Matched points in image %d and %d.\n', i,j); end               
        
    end
end
