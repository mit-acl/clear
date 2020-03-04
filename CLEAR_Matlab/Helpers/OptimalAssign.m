%% Optimal assignment via Hungarian algorithm
%
%
%
%
function Xi = OptimalAssign(Fi)

[a,c] = Hungarian(Fi); % Hungarian algorithm

% Associate observations to clusters
% Xi = zeros(numSmp(i), numObj);
Xi = zeros(size(Fi));
for ii = 1 : length(a)
    if (a(ii) ~= 0)
        Xi(ii,a(ii)) = 1;
    end
end