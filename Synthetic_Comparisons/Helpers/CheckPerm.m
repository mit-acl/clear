%% Check if components of an aggregate permutation matrix are permutations
%
%
function prmFlg = CheckPerm(TT, numSmp, numAgt)

idxSum = [0, cumsum(numSmp)]; % Cumulative index

prmFlg = true; % Set permutation flag to true
flag = false; % Flag to terminate the loops

for i = 1 : numAgt
    idxi = [idxSum(i)+1 : idxSum(i+1)];
    for j = 1 : numAgt
        idxj = [idxSum(j)+1 : idxSum(j+1)];
        
        Tij = TT(idxi, idxj) > 0.5; % Binarized permutation
        numRow = sum(Tij,1);
        numCol = sum(Tij,2);
        
        if any(numRow > 1) || any(numCol > 1)
            prmFlg = false;
            flag = true;
        end
        
        if flag
            break;
        end
        
    end
    
    if flag
        break;
    end
        
end





















































































