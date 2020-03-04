%% Estimate Number of objects in the universe
%
% Input:
%           - inp:        Lplacian matrix 'L', or vector of eigenvalues 'sl'
%
% Output:
%           - numObjEst:    Estimated number of objects in the universe
%           - sl:           Singularvalues of L
%
% Options:
%           - 'method':     'fixed' or 'gap'; Fixed threshold or Eigengap 
%           - 'multtype':   'sym' or 'randwalk; Multiplicaion type: symmetric or random walk
%           - 'thresh':     Threshold value for fixed method
%           - 'normalize':  Degree+I or only degree matrix  
%           - 'makesym':    Make L symmetric or not
%           - 'eigval':     If eigenvalues of Laplacian are provided directly
%           - 'feedback':   Display steps during execution
%
%
% If this program is useful, please cite:
%
% [1] K. Fathian, K. Khosoussi, P. Lusk, Y. Tian, J.P. How, "CLEAR: A 
%     Consistent Lifting, Embedding, and Alignment Rectification Algorithm 
%     for Multi-Agent Data Association", arXiv:1902.02256, 2019.
%
%
% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU lesser General Public License, either version 
% 3, or any later version. This program is distributed in the hope that it 
% will be useful, but WITHOUT ANY WARRANTY. 
%
% (C) Kaveh Fathian, 2019.  Email: kaveh.fathian@gmail.com
%
%% Changes:
%           - If eigenvalues are provided directly just estimates the size 
%
function [numObjEst, sl] = EstimateNumObj(inp, varargin)


% Paramters
feedback = false;   % Narrate steps during execution
normalize = 'DI';    % 'D' or 'DI';
multtype = 'sym';   % 'sym' or 'randwalk'
method = 'fixed';     % 'fixed' or 'gap';
thresh = 0.5;     % Threshold to estimate # of objets in the 'fixed' method
makesym = false;    % To make Laplacian matrix symmetric or not
eigval = false;     % If eigenvalues of Laplacian are provided 
L = inp;            % If input is a Laplacian matrix
numSmp = [];        % Number of observations for each agent

ivarargin = 1;
while ivarargin <= length(varargin)
    switch lower(varargin{ivarargin})
        case 'normalize'
            ivarargin = ivarargin+1;
            normalize = varargin{ivarargin};
        case 'multtype'
            ivarargin = ivarargin+1;
            multtype = varargin{ivarargin};
        case 'method'
            ivarargin = ivarargin+1;
            method = varargin{ivarargin};        
        case 'thresh'
            ivarargin = ivarargin+1;
            thresh = varargin{ivarargin};
        case 'makesym'
            ivarargin = ivarargin+1;
            makesym = varargin{ivarargin};
        case 'eigval'
            ivarargin = ivarargin+1;
            eigval = varargin{ivarargin};
        case 'feedback'
            ivarargin = ivarargin+1;
            feedback = varargin{ivarargin};
        case 'numsmp'
            ivarargin = ivarargin+1;
            numSmp = varargin{ivarargin};
        otherwise
            fprintf('Unknown option ''%s'' is ignored!',varargin{ivarargin});
    end
    ivarargin = ivarargin+1;
end




%%

if ~eigval % If L is provided compute the eigenvalues first
    
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
    D = diag(Ddig); % Normalizer
    
    
    % Multiplicaion type based on option
    if strcmp(multtype, 'sym')
        Lnrm = D * L * D; % Normalized Laplacian (symmetric)
    elseif strcmp(multtype, 'randwalk')
        Lnrm = D * D * L; % Normalized Laplacian (random walk)
    end
    
    
    if feedback, fprintf('Computing SVD of L...\n'); end
    P = L2P(L);
    A = P - diag(diag(P)); % Adjacency matrix of induced graph
    sl = BlockSVD(A, Lnrm); % Use block SVD to improve speed
%     sl = svd(Lnrm); % Get the spectrum
    
else
    sl = inp; % If eigenvalues are provided directly
end


if strcmp(method, 'fixed')
    
    numObjEst = nnz( sl < thresh ); % The number of eigencalue < thresh
    
    % Limit the estiamte
    numObjMin = max(numSmp); 
    numObjEst = max(numObjEst, numObjMin); % Minimum # of objects must not be less than max # of samples
    
elseif strcmp(method, 'gap')
    
    sd = abs(diff(sl)); % Spectral gap
    [~, srtIdx] = sort(sd, 'descend');
    numObjIdx = size(L,1) - srtIdx;
    
    if ~isempty(numSmp)
        % Limit the estiamte
        numObjMin = max(numSmp);
        numObjIdx(numObjIdx < numObjMin) = []; % Remove indices where size of universe is less than # of observations of an agent
    end
    
    numObjEst = numObjIdx(1);
    
end


% figure; 
% plot(sort(sl,'ascend'), 'LineStyle', 'none', 'Marker', '.');
% drawnow
























































































