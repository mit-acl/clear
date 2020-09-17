function Xi = SuboptimalNN(Fi)

numObsi = min(size(Fi));
Xi = zeros(size(Fi));
for ii = 1 : numObsi    
    [~,idx] = minmat(Fi); % Minimum elements in the matrix
    Xi(idx(1),idx(2)) = 1;
    Fi(:, idx(2)) = Inf;
    Fi(idx(1), :) = Inf;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Minimum element of a matrix and its index
function [m,idx] = minmat(A)  


sizA = size(A);
[m,id] = min(A(:));

r = rem(id,sizA(1));
a = r;
b = ((id-a)/sizA(1))+1;
if a == 0
    a = sizA(1);
    b = b-1;
else
    a = r;
    b = b;
end

idx = [a, b];
