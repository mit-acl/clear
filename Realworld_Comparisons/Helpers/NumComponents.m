% Find number of connected components


labels = GraphConnectedComp(Pb- eye(size(Pb))); % Label graph components

numCon = max(labels);

sizCom = zeros(1,numCon);
for i = 1 : numCon
    sizCom(i) = nnz(labels == i);
end






























