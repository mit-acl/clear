%% Choose pivot rows (rows that are orthogonal 
%
% Inputs: 
%           - U:       Matrix of eigenvectors
%           - numObj:  Number of objects
%
% Outputs: 
%           - C:       Matrix of pivot rows
%
%
%%
function C = PivotRows(U, numObj)

UU = abs( U * U' ); % Matrix of all inner products
pivIdx = zeros(numObj,1); % Index of pivot rows

pivIdx(1) = 1; % Take the first row as pivot
sumVec = UU(:,1); % Column of NN associated to the pivot
sumVec(1) = NaN; % Use 'NaN' to avoid choosing the same pivot in future iterations

% Find remaining pivots
for i = 2 : numObj 
    [~,idx] = min(sumVec, [], 'omitnan'); % Index of vector with smallest inner product to previous pivots
    pivIdx(i) = idx; 
    sumVec = sumVec + UU(:,idx); % Sum of inner products corresponding to chosen pivots
    sumVec(idx) = NaN;
end

C = U(pivIdx,:); % Cluster centers












