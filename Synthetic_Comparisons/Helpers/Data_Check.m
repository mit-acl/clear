function data = Data_Check(data)

numI = data.numI;
numJ = data.numJ;
numAlg = data.numAlg;
numItr = data.numItr;
PrmFlg = data.PrmFlg;
ConsFlg = data.ConsFlg;


prmChk = cell(numI, numJ); % Permutation check
consChk = cell(numI, numJ);  % Cycle-consistency check

prmItr = zeros(numItr,numAlg); 
consItr = zeros(numItr,numAlg);
for i = 1 : numI
    for j = 1 : numJ
        for itr = 1 : numItr % Stack data into a matrix
            prmItr(itr,:) = PrmFlg{i,j,itr}(1,:);     
            consItr(itr,:) = ConsFlg{i,j,itr}(1,:); 
        end
        prmChk{i,j} = all(prmItr, 1); % Permutation check
        consChk{i,j} = all(consItr, 1); % Cycle-consistency check
    end
end


data.prmChk = prmChk;
data.consChk = consChk;































































































