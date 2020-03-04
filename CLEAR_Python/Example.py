from CLEAR import CLEAR

# Noisy assignment matrix
P_in = [[1,0,1,0,0,0,0],
        [0,1,0,1,1,1,1],
        [1,0,1,1,0,0,0],
        [0,1,1,1,1,1,1],
        [0,1,0,1,1,1,1],
        [0,1,0,1,1,1,1],
        [0,1,0,1,1,1,1]]

# Number of agents and samples from each agent
numSmp = [2,1,1,1,1,1]
numAgt = 6

# Consistent assignment matrix, lifting matrices and the size of the universe
P_out, X, numObj = CLEAR(P_in, numSmp, numAgt)

print(P_out)
