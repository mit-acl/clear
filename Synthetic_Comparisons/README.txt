This package generates the precision-recall benchmark results reported in [1]. Algorithms included are:
- Spectral [2]
- MatchLift [3]
- MatchALS [4]
- MatchEIG [5]
- QuickMatch [6]
- NMFSynch [7]
- CLEAR [1]

Run "Compare_NumAgt.m" and "Compare_NumObs.m" in Matlab to generate the results. Precision-recall plots will be saved in the folder "SavedFigs". Run "Example.m" for a simple example that shows how the CLEAR algorithm is called. If this package is useful, please consider citing [1]. Feel free to send me an email with any questions or comments: kaveh.fathian@gmail.com


This package is tested in Matlab 2018a - 2019a, 64-bit Windows 10 OS. We noted that using an older version of Matlab may cause an error due to the incompatibility of some functions.

This program is free software: you can redistribute and/or modify it under the terms of the GNU lesser General Public License, either version 3, or any later version. This program is distributed in the hope that it will be useful, but without any warranty. 

(c) Kaveh Fathian, Kasra Khosoussi, Yulun Tian, Parker Lusk, Jonathan How. 2019.




[1] K. Fathian, K. Khosoussi, Y. Tian, P. Lusk, J.P. How, "CLEAR: A Consistent Lifting, Embedding, and Alignment Rectification Algorithm for Multi-View Data Association," arXiv:1902.02256, 2019.

[2] D. Pachauri, R. Kondor, V. Singh, "Solving the multiway matching problem by permutation synchronization," NIPS, 2013, pp. 1860–1868.

[3] Y. Chen, L. Guibas, Q. Huang, "Near-optimal joint object matching via convex relaxation," ICML, 2014, pp. 100–108.

[4] X. Zhou, M. Zhu, K. Daniilidis, "Multi-image matching via fast alternating minimization,"" ICCV, 2015, pp. 4032–4040.

[5] E. Maset, F. Arrigoni, A. Fusiello, "Practical and efficient multi-view matching," ICCV, 2017, pp. 4578–4586

[6] R. Tron, X. Zhou, C. Esteves, K. Daniilidis, "Fast multi-image matching via density-based clustering," ICCV, 2017, pp. 4077–4086.

[7] F. Bernard, J. Thunberg, J. Goncalves, C. Theobalt, "Synchronisation of partial multimatchings via non-negative factorisations," arXiv:1803.06320, 2018.
