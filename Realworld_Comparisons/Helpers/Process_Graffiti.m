%% Create cycle-consistent ground truth for Graffiti dataset
%
% Inputs:
%           - dataRoot:     Adderss to dataset
%           
% Outputs:
%           - Pr:           Ground truth association matrix
%           - numSmpR:      Number of feature points in each image
%           - numAgt:       Number of images
%           - numObj:       Number of universe objects
%           - imgDesR:      Image descriptors (SIFT)
%

function [Pr, numSmpR, numAgt, numObj, imgDesR, parOut] = Process_Graffiti(dataRoot, benchName, varargin)

saveFlag = false;

ivarargin = 1;
while ivarargin <= length(varargin)
    switch lower(varargin{ivarargin})
        case 'save'
            ivarargin = ivarargin+1;
            saveFlag = varargin{ivarargin}; 
        otherwise
            fprintf('Unknown option ''%s'' is ignored!',varargin{ivarargin});
    end
    ivarargin = ivarargin+1;
end



%% Parameters

numAgt = 6; % Number of images in the dataset
thresh = 1e-5; % Threshold to reject outlier matches


%% Path to the dataset files

% dataRoot = 'D:\Datasets\Graffiti';

% benchName = 'Graffiti';
% benchName = 'Bark';
% benchName = 'Bikes';
% benchName = 'Boat';
% benchName = 'Light';
% benchName = 'Trees';
% benchName = 'UBC';
% benchName = 'Wall';
 
dataPath = [dataRoot '\' benchName];


%% Read images and find SIFT features/descriptors

fprintf('Load images...\n');
files  = dir(dataPath);

imgNames = cell(1,numAgt);
imgRGB = cell(1,numAgt);
imgGray = cell(1,numAgt);
imgFeatures = cell(1,numAgt);    
numSmp = zeros(1,numAgt); % Number of feature points in each image
imgDescriptors = cell(1,numAgt); 

for i = 1 : numAgt
    imgNames{i} = files(i+7).name; 
    imgRGB{i} = imread([dataPath '\' imgNames{i}]);
    imgGray{i} = rgb2gray(imgRGB{i});

    % Extract SIFT feature points and descriptors
    fprintf('Extract SIFT feature points for image %d...\n', i);
    [features,descriptors] = vl_sift(im2single(imgGray{i})) ;

    imgFeatures{i} = features;
    imgDescriptors{i} = descriptors;
    numSmp(i) = size(features,2);

%     figure; imshow(imgRGB{i}); hold on
%     plot(features(1,:),features(2,:), 'g+', 'LineWidth', 1.5);
end


numSmpSum = sum(numSmp); % Total number of observations
idxSum = [0, cumsum(numSmp)]; % Cumulative index


%% Load and compute all pairwise ground truth homographies 

fprintf('Load ground truth homographies...\n');

homNames = cell(1,5);
H1i = cell(1,5);
Hom = cell(6,6);

for i = 1 : 5
    homNames{i} = files(i+2).name; 
    fileID = fopen([dataPath '\' homNames{i}]);
    H1i{i} = fscanf(fileID, '%e', [3,3])';        
    fclose(fileID);
    
    Hom{1,i+1} =  H1i{i}; % This is really H^i_1, i.e., mapping from agent 1 to agent i:  ^im = H1i * ^1m
    for j = 2 : i
        Hij = H1i{i} / H1i{j-1};
        Hom{j,i+1} =  Hij ./ Hij(3,3);
    end
end


%% Match feature points based on ground truth pose

close all
Dh = cell(numAgt, numAgt);
Xt = cell(numAgt, numAgt);
Pt = eye(numSmpSum);  % Ground truth aggregate permutation 

% thresh = 1e-4; % Threshold to reject outlier matches

% Reciprocal matches
for i = 1 : numAgt-1
    idxi = [idxSum(i)+1 : idxSum(i+1)];
    for j = i+1 : numAgt 
        idxj = [idxSum(j)+1 : idxSum(j+1)];
        
        % Feature point pixels 
        fi = imgFeatures{i}(1:2,:);
        fj = imgFeatures{j}(1:2,:);
        
        % Pairwise distance
        fprintf('Find pairwise distances...\n')
        Dij = PairDist(fi,fj,Hom{i,j}); % Order of inputs matter!
                
        % Suboptimal assignment
        fprintf('Suboptimal assignment...\n')
        Xij = SuboptimalNN(Dij);        
        
%         % Hungarian assignment
%         fprintf('Hungarian assignment...\n')
%         [a,c] = Hungarian(Dij);
%         Xij = zeros(size(Dij));
%         for ii = 1 : length(a)
%             if (a(ii) ~= 0)
%                 Xij(ii,a(ii)) = 1;
%             end
%         end        
        
        % Save match data
        Dh{i,j} = Dij;
        Dh{j,i} = Dij';
        Xt{i,j} = Xij;
        Xt{j,i} = Xij';
        Pt(idxi, idxj) = Xij;
        Pt(idxj, idxi) = Xij';
                
        fprintf('Matched points in image %d and %d.\n', i,j);                
        
    end
end

%% Check

% thresh = 1e-5;
% i = 1;
% j = 6;
% 
% Dij = Dh{i,j};
% Xij = Xt{i,j};
% idxXij = (Xij > 0.5); % Index of Xij elements equal to 1
% idxThresh = Dij > thresh; % Index of values in Dij > threshold 
% idxRmv = and(idxXij, idxThresh); % Index of Xij elements that should be removed
% Xij(idxRmv) = 0;
% 
% % Feature point pixels 
% fi = imgFeatures{i}(1:2,:);
% fj = imgFeatures{j}(1:2,:);
% 
% % Display image for debugging
% figure(1) ; clf ;
% imagesc(cat(2, imgRGB{i}, imgRGB{j})) ;
% 
% [idxi, idxj] = find(Xij);
% 
% xa = fi(1,idxi) ;
% xb = fj(1,idxj) + size(imgRGB{i},2) ;
% ya = fi(2,idxi) ;
% yb = fj(2,idxj) ;
% 
% hold on ;
% h = line([xa ; xb], [ya ; yb]) ;
% set(h,'linewidth', 0.1, 'color', 'y') ;
% axis image off ;


%% Thresholding (remove outliers using ground truth homography)

close all
Xth = cell(numAgt, numAgt);
Pth = eye(numSmpSum);  % Ground truth aggregate permutation 

% Reciprocal matches
for i = 1 : numAgt-1
    idxi = [idxSum(i)+1 : idxSum(i+1)];
    for j = i+1 : numAgt 
        idxj = [idxSum(j)+1 : idxSum(j+1)];
        
        Dij = Dh{i,j};
        Xij = Xt{i,j};
        idxXij = (Xij > 0.5); % Index of Xij elemts equal to 1
        idxThresh = Dij > thresh; % Index of values in Dij > threshold 
        idxRmv = and(idxXij, idxThresh); % Index of Xij elements that should be removed
        Xij(idxRmv) = 0;        
                
        % Save match data
        Xth{i,j} = Xij;
        Xth{j,i} = Xij';
        Pth(idxi, idxj) = Xij;
        Pth(idxj, idxi) = Xij';
                
        fprintf('Threshold matches in image %d and %d.\n', i,j);                
        
    end
end



%% Run BFS on induced graph to find:
% - single nodes (to remove)
% - cliques (to keep)
% Note: cliques are cycle-consistent matches across images

Ath = Pth - eye(size(Pth));
dth = sum(Ath,1); % Degree vector
labels = GraphConnectedComp(Ath);

numCom = max(labels); % Number of graph communities 
lblRmv = false(1,numSmpSum);
for i = 1 : numCom
    idx = (labels == i); % Nodes that belong to community i
    
    % Single nodes
    if nnz(idx) == 1
        lblRmv = or(lblRmv, idx);
        continue;
    end
    
    % Componenets that are not cliques
    deg = nnz(idx) - 1;
    degVec = dth(idx);
    if any(degVec ~= deg)
        lblRmv = or(lblRmv, idx);
    end
end

% Reduce number of samples, descriptors, and features to points that have ground truth matching
numSmpR = zeros(size(numSmp));
imgDesR = imgDescriptors;
imgFetR = imgFeatures;
for i = 1 : numAgt
    idxi = [idxSum(i)+1 : idxSum(i+1)];
    numSmpR(i) = numSmp(i) - nnz(lblRmv(idxi));
    imgDesR{i} = imgDescriptors{i}(:,~lblRmv(idxi));
    imgFetR{i} = imgFeatures{i}(:,~lblRmv(idxi));
end

% Remove single nodes and components that are not cliques
Pr = Pth;
Pr(lblRmv,:) = [];
Pr(:,lblRmv) = [];

% Original association with zeros
PthR = Pth;
PthR(lblRmv,:) = 0;
PthR(:,lblRmv) = 0;

% Number of objects
Ar = Pr - eye(size(Pr));
labels = GraphConnectedComp(Ar);
numObj = max(labels);


%% Output

parOut.Pth = Pth;
parOut.PthR = PthR;
parOut.imgFetR = imgFetR;
parOut.imgRGB = imgRGB;
parOut.imgGray = imgGray;


































































































