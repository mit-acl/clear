%% Parse ground truth for CMU Hotel dataset
%
% Inputs:
%           - dataRoot:     Adderss to dataset
%           
% Outputs:
%           - Pr:          Ground truth association matrix
%           - numSmp:      Number of feature points in each image
%           - numAgt:      Number of images
%           - numObj:      Number of universe objects
%           - imgDes:      Image descriptors (SIFT)
%

function [Pr, numSmp, numAgt, numObj, imgDes, parOut] = Process_CMUHotel(dataRoot, benchName, varargin)
% Options
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


%% Load ground truth data

% dataRoot = 'D:\Datasets\CMU Hotel';
% benchName = 'hotel';
% benchName = 'books';
% benchName = 'bldg';

dataPath = [dataRoot '\' benchName]; % Path to the dataset files

load(strcat(dataPath, '\', 'groundT.mat')); % Load ground truth data


%% Specific adjustments for each benchmark 

if strcmp(benchName, 'bldg') 
    data{1,1}(28,:) = [0, 0]; % Fix ground truth 
    data{1,7}(28,:) = [0, 0]; % Fix ground truth 
end

numAgt = size(data,2); % Number of agents (i.e., image frames)
numObj = size(data{1,1},1); % Total number of objects (i.e., features across all images)

imgNames = cell(1,numAgt); % Name of image files

if strcmp(benchName, 'hotel') 
    for i = 1 : numAgt
        imgNames{i} = strcat('hotel.seq', num2str(i-1), '.png'); 
    end
else
    files = dir([dataPath '\' '*.JPG']);
    for i = 1 : numAgt
        imgNames{i} = files(i).name;
    end
end


%% Read images and find SIFT features/descriptors

fprintf('Load images...\n');

imgRGB = cell(1,numAgt);
imgGray = cell(1,numAgt);
imgFeatures = cell(1,numAgt);    
numSmp = zeros(1,numAgt); % Number of feature points in each image
imgDescriptors = cell(1,numAgt);

for i = 1 : numAgt    
    % Load image
    imgRGB{i} = imread([dataPath '\' imgNames{i}]);
    if  strcmp(benchName, 'hotel')
        imgGray{i} = single(imgRGB{i});
    else
        imgGray{i} = im2single(rgb2gray(imgRGB{i}));
    end
    
    % Features in each image
    idxZro = all(data{1,i} == [0, 0], 2);
    feti =  data{1,i}(~idxZro,:)';
    numSmp(i) = numObj - nnz(idxZro);
        
    % Extract SIFT feature descriptors 
    fprintf('Extract SIFT feature points for image %d...\n', i);      
    fc = [feti; 10*ones(1, numSmp(i)); (pi/8)*ones(1, numSmp(i))];
    [features0,descriptors0] = vl_sift(imgGray{i},'frames',fc,'orientations');
    
    % Remove repeated features
    idx = false(1,size(features0,2));
    for j = 1 : numSmp(i)
        [~,midx] = min( vecnorm(features0(1:2,:) - fc(1:2,j)) );
        idx( midx ) = true;
    end
    features = feti;
    descriptors = descriptors0(:,idx);
    
    imgFeatures{i} = features;
    imgDescriptors{i} = descriptors;    
end


%% Ground truth associations 

fprintf('Generating ground truth associations...\n');  

numSmpSum = sum(numSmp); % Total number of observations
idxSum = [0, cumsum(numSmp)]; % Cumulative index
Y = zeros(numSmpSum, numObj); % Lifting permuation matrix

% Reciprocal matches
for i = 1 : numAgt
    idxi = [idxSum(i)+1 : idxSum(i+1)];
    
    Yi = eye(numObj); % Lifting permutation matrix for agent i
    idxZro = all(data{1,i} == [0, 0], 2); % Index of missing observations     
    Yi(idxZro,:) = []; % Remove rows 
    
    Y(idxi,:) = Yi;    
end

% Aggregate inter-agent permutation matrix
Pr = Y * Y';


%% Check

% i = 1;
% j = 6;
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



%% Output

imgDes = imgDescriptors;
parOut.imgFet = imgFeatures;
parOut.imgRGB = imgRGB;
parOut.imgGray = imgGray;

fprintf('Done.\n');



























































































