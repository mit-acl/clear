%% Simple example for applicaion of CLEAR algorithm
%
% If this program is useful, please consider citing:
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
% (C) Kaveh Fathian, 2020.  Email: kavehfathian@gmail.com
%
%% Set path

addpath('Helpers');
addpath('..\Synthetic_Comparisons\Helpers');


%% Load example data

load('ExData.mat'); 


%% CLEAR algorithm

[Pout, Puni, numObjEst] = CLEAR(Pin, numSmp, numAgt); % Call CLEAR algorithm
% [Pout, Puni] = CLEAR(Pin, numSmp, numAgt, 'numobj', numObj); % Call CLEAR algorithm with specified number of objects


%% Results

[~, ~, pinp,rinp] = ErrorMetric(Pin, Pref, Pin, numSmp, numAgt, 'fscore'); % Precision-recall of input
[~, ~, pout,rout] = ErrorMetric(Pout, Pref, Pin, numSmp, numAgt, 'fscore'); % Precision-recall of output

fprintf('Noisy input with precision of %f and recall of %f.\n', pinp, rinp);
fprintf('Output of CLEAR has precision of %f and recall of %f.\n', pout, rout);
fprintf('Size of universe estimated by CLEAR is %d.\n\n', numObjEst);











































