function P = matrix2permutation(U)
% MATRIX2PERMUTATION project matrix U onto a permutation P 
%       This function applies a greedy strategy to project matrix U onto a
%       valid permutation (not the closest one). This strategy is
%       approximate but produces no significant loss in accuracy with
%       respect to the Kuhn-Munkres algorithm, while boosting the speed.% 
% ----- Input:
%       U: matrix with unconstrained entries
% ----- Output:
%       P: partial permutation matrix with at most one nonzero entry in 
%          each row and column
% ----- Authors:
%       Eleonora Maset, Federica Arrigoni and Andrea Fusiello, 2017  
%       Practical and Efficient Multi-view Matching, ICCV17

[r,c] = size(U);
% inizialize output permutation matrix P
P = sparse(r,c);

% compute the maximum over the rows
[max_r,ind_r] = max(U,[],2); 
% compute the maximum over the columns
[max_c,ind_c] = max(U',[],2);

% sort the maximum values in descending order
[max_rc,ind] = sort([max_r;max_c],'descend');
rw = [(1:r)';ind_c];
cl = [ind_r;(1:c)'];
rw = rw(ind);
cl = cl(ind);

% delete maximum values corresponding to zero entries of U
rw(max_rc==0) = [];
cl(max_rc==0) = [];

% examine sequentially the maximum values starting from the largest
for k = 1:length(rw)
    if sum(P(rw(k),:)) == 0 && sum(P(:,cl(k))) == 0 
        % if P remains a partial permutation
        P(rw(k),cl(k)) = 1;
    end    
end

end