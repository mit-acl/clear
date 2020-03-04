%% Normalize Laplacian matrix
%
% Input:
%           - L:        Lplacian matrix
%
% Output:
%           - Lnrm:     Normalized Laplacian matrix
%
% Options:
%           - 'normalize':  Degree+I or only degree matrix  
%           - 'multtype':   Multiplicaion type: symmetric or random walk
%           - 'makesym':    Make L symmetric or not
%
%% Changes:
%       - Normalize by direct division on each element to improve speed
%
function [Lnrm] = NormalizeLap(L, varargin)

% Paramters
normalize = 'DI'; % 'D' or 'DI';
multtype = 'sym'; % 'sym' or 'randwalk'
makesym = false; 

ivarargin = 1;
while ivarargin <= length(varargin)
    switch lower(varargin{ivarargin})
        case 'normalize'
            ivarargin = ivarargin+1;
            normalize = varargin{ivarargin};
        case 'multtype'
            ivarargin = ivarargin+1;
            multtype = varargin{ivarargin};
        case 'makesym'
            ivarargin = ivarargin+1;
            makesym = varargin{ivarargin};
        otherwise
            fprintf('Unknown option ''%s'' is ignored!',varargin{ivarargin});
    end
    ivarargin = ivarargin+1;
end



%% Normalize Laplacian

% Take symmetric part of L if option specified
if makesym
    L = (L + L') /2;
end


% Normalize L according to option specified
Ldig = diag(L); % Diagonal of L
if strcmp(normalize, 'DI')    
    Ddig = 1 ./ sqrt(Ldig+1); % Diagonal of normalizer    
elseif strcmp(normalize, 'D')
    Ddig = 1 ./ sqrt(Ldig); % Diagonal of normalizer
    Ddig(Ldig == 0) = 0;
end


[rIdx, cIdx] = find(L); % row and column location of off-diagonal elements

Lnrm = L; % Preallocate
for i = 1 : size(rIdx,1)
    r = rIdx(i);
    c = cIdx(i);
    
    % Multiplicaion type based on option
    if strcmp(multtype, 'sym') 
        Lnrm(r,c) = L(r,c) * Ddig(r) * Ddig(c);
    elseif strcmp(multtype, 'randwalk')
        Lnrm(r,c) = L(r,c) * Ddig(r) * Ddig(r);
    end
end




% % Normalize L according to option specified
% Ldig = diag(L); % Diagonal of L
% if strcmp(normalize, 'DI')    
%     Ddig = 1 ./ sqrt(Ldig+1); % Diagonal of normalizer    
% elseif strcmp(normalize, 'D')
%     Ddig = 1 ./ sqrt(Ldig); % Diagonal of normalizer
%     Ddig(Ldig == 0) = 0;
% end
% D = diag(Ddig); % Normalizer
% 
% 
% % Multiplicaion type based on option
% if strcmp(multtype, 'sym')    
%     Lnrm = D * L * D; % Normalized Laplacian (symmetric)
% elseif strcmp(multtype, 'randwalk')
%     Lnrm = D * D * L; % Normalized Laplacian (random walk)
% end 














