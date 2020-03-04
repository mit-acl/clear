%% Suboptimal assignment (instead of Hungarian) to improve speed
%
%
%
%
function Xi = SuboptimalAssign(Fi)


numObsi = size(Fi,1); % Number of observations of agent i

assign = zeros(numObsi, 1); % Assignment labels
Fi0 = Fi;
while any(assign == 0)
    rowid = find(assign == 0); % Index of rows not assigned
    [~, idx] = min(Fi0(rowid,:), [], 2); % Find column index of smallest element in each row
    for i = 1 : length(rowid)
        if assign(rowid(i)) == 0 % If no prior assignment
            idset = find(idx == idx(i)); % Find if we have repeated assignments
            if nnz(idset) == 1 % Check if assignment is unique
                assign(rowid(i)) = idx(i); % Assign column index to observation
                Fi0(:,idx(i)) = Inf; % Set elements to Inf to indicate column is assinged
            else % Repeated assignment indicies
                [~, idx1] = min(Fi0(rowid(idset), idx(i))); % Find min elements to resolve conflict
                assign(rowid(idset)) = -1; % Temporarily set assignment for all conflicts to -1
                assign(rowid(idset(idx1))) = idx(i); % Set assignment for best candidate
                Fi0(:,idx(i)) = Inf; % Set elements to Inf to indicate column is assinged
            end
        end
    end
    assign(assign == -1) = 0; % Set undetermined assignment to zero    
end

Xi = zeros(size(Fi)); % Preallocate assignment matrix
for i = 1 : numObsi    
    Xi(i,assign(i)) = 1;
end



