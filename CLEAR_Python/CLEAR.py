import numpy as np
import util

def CLEAR(TT, numSmp, numAgt, numObj=None):
    """
    CLEAR algorithm (Consistent Laplacian Estimatmion and Aberrancy Reduction)

    Parameters
    ----------
    TT : numpy.ndarray
        Initial permutations (aka. correspondences or score matrices)
    numSmp : numpy.ndarray
        Number of observations for each agent
    numAgt : int
        Number of agents (aka. frames or observations)
    numObj : int, optional
        Number of objects in the universe. The default is None. If None, 
        numObj will be estimated from the sepctrum of Laplacian automatically.
    
    Returns
    -------
    XX : numpy.ndarray
        Consistent pairwise permutations
    X : numpy.ndarray
        Map to universe (lifting permutations)
    numObj : int
        Estimated number of objects
    """
    
    # Also work with regular array input
    TT = np.array(TT)
    numSmp = np.array(numSmp)
    
    idxSum = np.append([0], np.cumsum(numSmp)) # Cumulative index
    numSmpSum = np.sum(numSmp) # Total number of observations
    
    if numSmpSum != TT.shape[0]:
        raise ValueError("Incorrect number of samples.")
    
    P = (TT + TT.T)/2 # Make association matrix symmetric
    for i in range(numAgt): # Remove any self associations (distinctness constraint)
        l,r = idxSum[i], idxSum[i+1]
        P[l:r, l:r] = np.eye(numSmp[i]) # Block of P associated to agent i
        
    A = P - np.diag(np.diag(P)) # Adjacency matrix of induced graph
    L = util.P2L(P) # Graph Laplacian matrix
    
    # Normalize L
    Lnrm = util.normalize_lap(L, "DI", "sym")
    
    # Compute SVD using union of connected components' SVDs (to improve speed)
    sl, Vl = util.block_svd(A, Lnrm)

    # Estimate size of universe if not provided
    if numObj == None:
        numObj, _ = util.estimate_num_obj(sl, eigval=True, numSmp=numSmp)
        
    # Get the null space
    U0 = Vl[:, -numObj:] # Kernel
    U = U0/np.linalg.norm(U0, axis=1, keepdims=True) # Normalize each row of U0
    
    # Find cluster center candidates
    C = util.pivot_rows(U, numObj)
    
    # Distance to cluster centers
    F = 1 - np.matmul(U, C.T)

    # Solve linear assignment
    X = np.zeros(F.shape)
    for i in range(numAgt):
        l,r = idxSum[i], idxSum[i+1]
        Fi = F[l:r, :] # Component of F associated to agent i
        
        # Suboptimal linear assignment
        Xi = util.suboptimal_assignment(Fi)
        
        X[l:r, :] = Xi # Store results
        
    # Pairwise assignments
    XX = np.matmul(X, X.T)
    
    return XX, X, numObj