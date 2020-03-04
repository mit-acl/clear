%% Permutation error metric
%
% Inputs:
%
%           - TT:           Recovered matrix
%           - TTref:        Ground truth matrix
%           - TTmis:        Baseline matrix
%           - numSmp:       Number of observations for each agent
%           - numAgt:       Number of agents
%
% Outputs:
%   
%           - err:          Absolute error
%           - errPerc:      Percentage of error (0 to 1)
%
% Options:
%
%           - 'nuc':        Nuclear norm
%           - 'fscore':     F-score (should use only when input is
%                           permutation matrix)
%
%
%% Changes: 
%           - Retuns precision-recall
%           - Based on well-defined matrix norms (Frobenius)
%           - Added F-score as option 'fscore' 
%           - Modified for partially matched case
%
%
function [err, errPerc, p,r] = ErrorMetric(TT, TTref, TTmis, numSmp, numAgt, varargin)

% Options
fscore = false; 
nuc = false; % Nuclear norm
fro = true; % Frobenius norm
adj = []; % adjacency matrix
p = [];
r = [];

ivarargin = 1;
while ivarargin <= length(varargin)
    switch lower(varargin{ivarargin})
        case 'fscore'
            fscore = true;  fro = false;
        case 'nuc'
            nuc = true;  fro = false;
        case 'adj'
            ivarargin = ivarargin+1;
            adj = varargin{ivarargin}; 
        otherwise
            fprintf('Unknown option ''%s'' is ignored!',varargin{ivarargin});
    end
    ivarargin = ivarargin+1;
end


%% Apply adjacency constraint

if ~isempty(adj)

idxSum = [0, cumsum(numSmp)]; % Cumulative index

for i = 1 : numAgt
    idxi = [idxSum(i)+1 : idxSum(i+1)];
    for j = 1 : numAgt
        idxj = [idxSum(j)+1 : idxSum(j+1)];        
        if ~adj(i,j)
            TT(idxi, idxj) = 0;
            TTref(idxi, idxj) = 0;
            TTmis(idxi, idxj) = 0;
        end
    end
end

end


%% Error based on matrix norm

TTErr = TT - TTref;
TTErrTot = TTmis - TTref;


if fro
    
err = norm(TTErr, 'fro'); % Frobenius norm
maxErr = norm(2*TTref, 'fro'); % Maximum error that can occur
errPerc = err / maxErr; % Error percentage

elseif nuc
    
err = sum(svd(TTErr)); % Nuclear norm    
maxErr = sum(svd(2*TTref)); % Maximum error that can occur    
errPerc = err / maxErr; % Error percentage
    
end



%% F-score error

if fscore    
    % Remove diagonals
    TT = TT - diag(diag(TT));
    TTref  = TTref  - diag(diag(TTref ));
    
    % Turn to logical array
    TT = TT > 0.5;
    TTref = TTref > 0.5;
    
    % Correct matches
    TTcorrect = TT & TTref;
    
    % Precision    
    p = nnz(TTcorrect) / (nnz(TT)+eps);

    % Recall
    r = nnz(TTcorrect) / (nnz(TTref)+eps);

    % F-score
    F = 2 * (p*r)/(p+r+eps);

    errPerc = 1 - F;
    err = errPerc;
end












































































