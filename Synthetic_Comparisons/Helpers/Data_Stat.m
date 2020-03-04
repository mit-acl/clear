function data = Data_Stat(data)

numI = data.numI;
numJ = data.numJ;
numAlg = data.numAlg;
numItr = data.numItr;
Err = data.Err;
Pre = data.Pre;
Rec = data.Rec;
Tim = data.Tim;


ErrMean = cell(numI, numJ);
PreMean = cell(numI, numJ);
RecMean = cell(numI, numJ);
ErrVar = cell(numI, numJ);
TimMean = cell(numI, numJ);

errItr = zeros(numItr,numAlg);
preItr = zeros(numItr,numAlg);
recItr = zeros(numItr,numAlg);
timItr = zeros(numItr,numAlg);
for i = 1 : numI
    for j = 1 : numJ
        for itr = 1 : numItr % Stack data into a matrix
            errItr(itr,:) = Err{i,j,itr};
            preItr(itr,:) = Pre{i,j,itr};
            recItr(itr,:) = Rec{i,j,itr};
            timItr(itr,:) = Tim{i,j,itr};
        end
        % Find mean and variance
        ErrMean{i,j} = mean(errItr,1);        
        ErrVar{i,j} = var(errItr,0,1);
        PreMean{i,j} = mean(preItr,1);
        RecMean{i,j} = mean(recItr,1);
        TimMean{i,j} = mean(timItr,1);
    end
end


data.ErrMean = ErrMean;
data.ErrVar = ErrVar; 
data.PreMean = PreMean; 
data.RecMean = RecMean;
data.TimMean = TimMean;















































































































