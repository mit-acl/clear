# CLEAR: Consistent Lifting, Embedding, and Alignment Rectification Algorithm

The Matlab, Python, and C++ implementation of the CLEAR algorithm, as described in [[1]](https://arxiv.org/abs/1902.02256), is provided.

[1] K. Fathian, K. Khosoussi, Y. Tian, P. Lusk, J.P. How, "CLEAR: A Consistent Lifting, Embedding, and Alignment Rectification Algorithm for Multi-View Data Association", [arXiv:1902.02256](https://arxiv.org/abs/1902.02256), 2019.

## Video:
A video describing the CLEAR algorithm is available at


## Matlab syntax:
```
[Pout, Puni, numObjEst] = CLEAR(Pin, numSmp, numAgt)
```

### Description:
``[Pout, Puni, numObjEst] = CLEAR(Pin, numSmp, numAgt)`` applies the CLEAR algorithm on the aggregate association matrix ``Pin`` and returns the cycle consistent association matrix ``Pout``. Variable ``numAgt`` is the number of views or agents, and ``numSmp`` is a vector that contains the number of observations at each view. CLEAR further returns lifting associations to universe ``Puni`` and the estimated size of universe ``numObjEst``.  


### Example:
Run "Example.m" for a simple example that shows how the CLEAR algorithm is called.


### Options and tips: 
If the number of objects is known, call the algorithm with the option
```
Pout = CLEAR(Pin, numSmp, numAgt, 'numobj', numObj)
```
where ``numObj`` is the number of objects. Otherwise, the algorithm automatically estimates the number of objects from the spectrum of the normalized Laplacian matrix.


## Synthetic comparisons:
Run files in the "Synthetic_Comparisons" folder to compare CLEAR with state-of-the-art algorithms.


## Copyright:

If this program is useful, please consider citing [[1]](https://arxiv.org/abs/1902.02256). This package is tested in Matlab 2018a - 2019a, 64-bit Windows 10 OS. We noted that using an older version of Matlab may cause an error due to the incompatibility of some functions.


This program is free software: you can redistribute and/or modify it under the terms of the GNU lesser General Public License, either version 3, or any later version. This program is distributed in the hope that it will be useful, but without any warranty. 


(c) Kaveh Fathian, Kasra Khosoussi, Yulun Tian, Parker Lusk, Jonathan How. 2020.


