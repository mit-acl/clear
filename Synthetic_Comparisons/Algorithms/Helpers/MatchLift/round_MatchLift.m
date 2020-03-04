% Implement the rounding heuristic suggested by matchlift
% Input:
%   TT: fractional adjacency matrix from MatchLift
%   numSmp: number of observations owned by each agent
%   numObjEst: estimated number of objects in the universe
%   threshold: similarity threshold to create new landmark in
%              the universe (see MatchLift paper)
% Output:
%   TT_round: rounded adjacency matrix
%   P_round: rounded permutation to universe
%
%
% (c) Yulun
%
%
function [TT_round, P_round] = round_MatchLift(TT, numSmp, numObjEst, threshold)

numAgt = length(numSmp);
cumsum_ = cumsum(numSmp);

% Take eigen-decomposition of TT
[U,D] = eigs(TT,numObjEst,'largestabs');
% Recover embeddeing V
V = U * sqrt(D);

universe_size = 0;
% Initialize fixed array
fixed = zeros(1, size(V,1));
% Initialize assignment vector
assignment = zeros(1, size(V,1)); 

% While there exists vertices that are not fixed
while sum(fixed) ~= size(V,1)
    % find all vertices that are not yet assigned
    free_indices = find(fixed == 0);
    % find the next vertex that is free
    i_curr = free_indices(1);
    v_curr = V(i_curr, :);
    % find agent that owns this vertex
    a = cumsum_ >= i_curr;
    b = find(a > 0);
    agt_curr = b(1);
    
    % initialize a new landmark in the universe
    landmark_id = universe_size + 1;
    universe_size = universe_size + 1;
    
    % assign this vertex to the new landmark
    assignment(i_curr) = landmark_id;
    fixed(i_curr) = 1;
    
    % go through each agent
    for agt_next = agt_curr+1: numAgt
        % find vertices owned by agt_next
        last_idx = cumsum_(agt_next);
        first_idx = last_idx - numSmp(agt_next) + 1;
        idxs = first_idx:last_idx;
        % find the vertex owned by agt_next that is most similar to v_curr
        max_index = idxs(1);
        max_score = -1e3;
        for index = idxs
           if fixed(index) == 1
              continue; 
           end
           v_cand =  V(index,:);
           score = sum(v_cand.*v_curr);
           if score > max_score
              max_score = score;
              max_index = index;
           end
        end
        
        if max_score >= threshold
           % match this vertex with v_curr, i.e., assign it to the same
           % landmark in the universe
           assert(fixed(max_index) == 0);
           fixed(max_index) = 1;
           assignment(max_index) = landmark_id;
        end
    end
end

%% Form output matrices
P_round = sparse(size(V,1), universe_size);
for i = 1:size(V,1)
    li = assignment(i);
    P_round(i,li) = 1;
end

TT_round = P_round * P_round';

% fprintf('MatchLift rounding done. Total number of objects created: %g. Elapsed time: %g\n', universe_size, toc);

end