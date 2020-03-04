%% Precision-recall comparison of percentage of observations vs percentage of mismatches
%
% If this package is useful, please consider citing:
%
% [1] K. Fathian, K. Khosoussi, P. Lusk, Y. Tian, J.P. How, "CLEAR: A 
%     Consistent Lifting, Embedding, and Alignment Rectification Algorithm 
%     for Multi-Agent Data Association", arXiv:1902.02256, 2019.
%
%
% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU lesser General Public License, either version 
% 3, or any later version. This program is distributed in the hope that it 
% will be useful, but WITHOUT ANY WARRANTY. 
%
% (C) Kaveh Fathian, 2019.  Email: kaveh.fathian@gmail.com
%
%
%% Set path

addpath('Helpers');
addpath(genpath('Algorithms'));
addpath(genpath('..\CLEAR_Matlab'));


%% Simulation parameters

rangeObs = (.2 : .2 : 1.0);     % Range of observation probabilities  
rangeMismch = (5 : 5 : 25);     % Range of mismatch percentage in the input data
numObj = 100;                   % Number of world objects 
numAgt = 10;                    % Number of agents

% Number of Monte Carlo iterations for each set of parameters (reduce this to increase simultaion speed)
numItr = 10; 

rng(0,'twister'); % Reset the random number generator (for repeatability of the results)


%% Set parameters and preallocate variables

% Set simulatino paramteres 
par.init = [];
par = Param_Set(par, 'numObj',numObj, 'numAgt',numAgt);

% Preallocate variables that store the results in data structure
data = Data_Allocate(rangeMismch, rangeObs, numItr);


%% Run comparisons

for i = 1 : data.numI
    for j = 1 : data.numJ        
        par.misPerc = rangeMismch(i);   % Mismatch percentage
        par.smpMen = rangeObs(j) * numObj; % Percentage of observations
        fprintf('Loop (%i,%i) of (%i,%i)...\n', i,j, data.numI,data.numJ);
        
        for itr = 1 : numItr
            
            % Benchmarking algorithms
            [Pr, Pb, numSmp, numAgt, par] = SyntheticData(par); % Generate synthetic data
            results = CompareAlgs(Pb, Pr, numSmp, numAgt, par); % Generate precision-recall results
            
            data = Data_Store(data, results, i,j,itr); % Store results in data structure   
            
            fprintf('Iteration %i of %i.\n', itr, numItr); 
        end        
    end
end

data.numAlg = length(results.AlgBin); % Number of tested algorithms
data.algs = results.AlgBin; % Get name of algorithms


%% Generate statistics of the results

data = Data_Stat(data); % Statistics


%% Merge results of cycle-consistency and permutation checks

data = Data_Check(data); 


%% Show results  

algs = results.AlgBin; % Get name of algorithms

parPlot.XLabel = 'Mismatch percentage';
parPlot.YLabel = 'Observation probability';
fileName = 'NumObs'; % Plot name

% Generate plot - NOTE: results are saved in the folder 'Savedfigs'
PlotErr2D(data, fileName, parPlot); 











































































