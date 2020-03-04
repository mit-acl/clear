% 
% Mex implementation of Bertsekas' auction algorithm [1] for a very fast
% solution of the linear assignment problem.
%
% The implementation is optimised for sparse matrices where an element
% A(i,j) = 0 indicates that the pair (i,j) is not possible as assignment.
% Solving a sparse problem of size 950,000 by 950,000 with around
% 40,000,000 non-zero elements takes less than 8 mins. The method is also
% efficient for dense matrices, e.g. it can solve a 20,000 by 20,000
% problem in less than 3.5 mins.
%
% Both, the auction algorithm and the Kuhn-Munkres algorithm have
% worst-case time complexity of (roughly) O(N^3). However, the average-case
% time complexity of the auction algorithm is much better. Thus, in
% practice, with respect to running time, the auction algorithm outperforms
% the Kuhn-Munkres (or Hungarian) algorithm significantly.
%
% Note that only global optima are found for integer-valued benefit
% matrices. For real-valued benefit matrices a scaling of the values needs
% to be applied by multiplication with a large number. This scaling factor
% depends on the desired accuracy, as the global solution is found for the
% integral part of the benefit matrix, whilst there is no guarantee that
% the fractional part of the benefits are properly taken into account.
% However, in practical cases it seems advantageous to not round the
% resulting benefit matrix and retain the fractional parts in the benefit
% matrix. Also note that larger scalings of the benefit matrix increase the
% run-time, so a problem-specific trade-off between runtime and accuracy
% must be chosen.
%
% Input:
%               A                       N-by-N sparse benefit matrix
%                                       (higher values indicate a better 
%                                       match, the value 0 indicates 
%                                       inadmissable assignments)
%               [epsilon]               Initial value of epsilon (optional)
%               [epsilonDecreaseFactor] Decrease factor of epsilon
%                                       (optional)
%               [verbosity]             level of verbosity (0: quiet, 1:
%                                       general infos, 2: full infos)
%                                       (optional)
%               [doFeasibilityCheck]    Flag if feasibility check should be
%                                       performed. This may have negative
%                                       impact on the runtime. So if you
%                                       know that your input has a
%                                       feasibile solution, set it to 0 for
%                                       improved performance. Also, the
%                                       feasibility is based on Matlab's
%                                       dmperm() function, which crashes
%                                       for very large matrices.
%
% Output:
%               assignments             Resulting assignments. If there is
%                                       no feasible solution, all
%                                       assignments are -1.
%               [P]                     Permutation matrix output, such
%                                       that trace(P*A') gives the optimal
%                                       value
%               [prices]                Prices used during auctions
%                                       (optional)
%
% Example:      See the function test() below for a usage example.
%               Typically only the benefit matrix A is given as input and
%               the first or second output argument is relevant. epsilon
%               and epsilonDecreaseFactor can be used to heuristically
%               adapt runtime.
%
% Compilation:  mex -largeArrayDims auctionAlgorithmSparseMex.cpp -lut
%           
% When using this implementation in your work, in addition to [1] you are
% required to cite [2].
%
% [1]	Bertsekas, D.P. 1998. Network Optimization: Continuous and Discrete
%       Models. Athena Scientific.
%
% [2]   Bernard, F., Vlassis, N., Gemmar, P., Husch, A., Thunberg, J.,
% 	    Goncalves, J. and Hertel, F. 2016. Fast correspondences for
% 	    statistical shape models of brain structures. SPIE Medical Imaging,
% 	    San Diego, CA, 2016.
%
% Implementation by Florian Bernard ( f.bernardpi [at] gmail [dot] com ).
%
% Thanks to Guangning Tan for helpful feedback. If you want to use the
% Auction algorithm without Matlab, please check out Guangning Tan's C++
% interface, available here: https://github.com/tgn3000/fastAuction .
%
% Last modified on 25/03/2019
%

function [assignments, P, prices] = ...
	sparseAssignmentProblemAuctionAlgorithm(A, epsilon, ...
	epsilonDecreaseFactor, verbosity, doFeasibilityCheck)

	N = size(A,1);

	if ( any(A(:)<0) )
		error('Only non-negative benefits allowed!');
	end

	if ( ~issparse(A) )
		warning('Converting A to sparse matrix!');
		A = sparse(A);
	end
	
	if ( ~exist('doFeasibilityCheck', 'var') )
		doFeasibilityCheck = 1;
	end

	% heuristic for setting epsilon
	A = A*(N+1);
	maxAbsA = full(max(abs(A(:))));
	if ( ~exist('epsilon', 'var') || isempty(epsilon) )
		epsilon = max(maxAbsA/50, 1);
% 		epsilon = 0.5*((N*maxAbsA)/5 + N*maxAbsA); % see page 260 in [1]
	end

	if ( ~exist('epsilonDecreaseFactor', 'var') || isempty(epsilonDecreaseFactor) )
		epsilonDecreaseFactor = 0.2;
	end
	
	if ( ~exist('verbosity', 'var') )
		verbosity = 0;
	end
	
	if ( doFeasibilityCheck )
		[~,~,r,s] = dmperm(A);
		if ( any(r~=s) )
			warning('No feasible solution exists');
			P = [];
			assignments = -ones(1,N);
			return;
		end
	end
	
	[assignments, prices] = ...
		auctionAlgorithmSparseMex(A', epsilon, epsilonDecreaseFactor, ...
		maxAbsA, verbosity);
	P = sparse(1:N, assignments', ones(1,N), N,N);
end


function test()
%% DEMO
	% compile mex file
	mex -largeArrayDims auctionAlgorithmSparseMex.cpp -lut
	
	% create sample data
	N = 2000;
	
	A = rand(N,N);
	
	% create sparse matrix, since the mex implementation uses the Matlab
	% sparse matrix data structure
	A = sparse(A);

	% scale A such that round(Ascaled) has sufficient accuracy
	scalingFactor = 10^6;
	Ascaled = A*scalingFactor;
	
	% solve assignment problem
	tic
	[assignments,P] = sparseAssignmentProblemAuctionAlgorithm(Ascaled);
	toc
end
