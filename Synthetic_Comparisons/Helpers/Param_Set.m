function par = Param_Set(par, varargin)
%% Parse input

% Preallocate paramters
numObj = 100;           % Number of world objects
numAgt = 5;             % Number of agents
obsPrb = 0.5;           % Observation probability of an object
misPerc = 0;            % Mismatch percentage (0 - 100)
smpStd = 0;             % Standard deviation of number of object samples

ivarargin = 1;
while ivarargin <= length(varargin)
    switch lower(varargin{ivarargin})
        case 'numobj'
            ivarargin = ivarargin+1;
            numObj = varargin{ivarargin};
        case 'numagt'
            ivarargin = ivarargin+1;
            numAgt = varargin{ivarargin};
        case 'obsprb'
            ivarargin = ivarargin+1;
            obsPrb = varargin{ivarargin};    
        case 'misperc'
            ivarargin = ivarargin+1;
            misPerc = varargin{ivarargin}; 
        case 'smpstd'
            ivarargin = ivarargin+1;
            smpStd = varargin{ivarargin};
        otherwise
            fprintf('Unknown option ''%s'' is ignored!',varargin{ivarargin});
    end
    ivarargin = ivarargin+1;
end


%% 

% Specify algorithms to run. Can be 'true' or 'false'
par.runMchlft = false; % !! We noted that running MatchLift on large matrices may crash the computer !!
par.runMchALS = true; 
par.runNMFSync = true;
par.runSpec = true;
par.runSpecKF = false;
par.runMchEig = true;
par.runQMch = true;
par.runCLEAR = true;


% Flag to estimate the number of objects or use the ground truth number (use 'false' for ground truth and 'true' for estimate)
par.estimateNumObj = true; 



%% Preallocate 

par.numAgt = numAgt;                % Number of agents
par.numObj = numObj;                % Number of world objects
% par.smpMen = numObj;              % Mean of number of object samples
par.smpMen = obsPrb * numObj;       % Mean of number of object samples
par.smpStd = smpStd;                % Standard deviation of number of object samples
% par.smpStd = numObj / 6;          % Standard deviation of number of object samples
par.misPerc = misPerc;              % Mismatch percentage (0 - 100)































































































