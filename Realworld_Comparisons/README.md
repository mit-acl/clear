# CLEAR: Consistent Lifting, Embedding, and Alignment Rectification Algorithm

The Matlab, Python, and C++ implementation of the CLEAR algorithm, as described in:

K. Fathian, K. Khosoussi, Y. Tian, P. Lusk, J.P. How, "CLEAR: A Consistent Lifting, Embedding, and Alignment Rectification Algorithm for Multi-View Data Association", [arXiv:1902.02256](https://arxiv.org/abs/1902.02256), 2019.


## Realworld comparisons:
Run files "Benchmark_CMUHotel" and "Benchmark_Graffiti" to compare CLEAR with state-of-the-art algorithms for image feature matching on realworld datasets of CMU Hotel and Graffiti.


### Notes: 
- To test the code for all sequences, you need to download the full datasets separately and include them in the folder "Dataset" before running the code. These datasets are available at: 
[http://www.robots.ox.ac.uk/~vgg/data/data-aff.html](http://www.robots.ox.ac.uk/~vgg/data/data-aff.html)
[http://pages.cs.wisc.edu/~pachauri/perm-sync/](http://pages.cs.wisc.edu/~pachauri/perm-sync/)

- For machines other than Windows 64, you need to download and compile the VLFeat library (in the folder "VLFeat") before running the code. This library is used to extract and match SIFT image features. This library is available at:
[https://www.vlfeat.org/](https://www.vlfeat.org/)


## Copyright:

If this program is useful, please consider citing [[1]](https://arxiv.org/abs/1902.02256). This package is tested in Matlab 2018a - 2019a, 64-bit Windows 10 OS. We noted that using an older version of Matlab may cause an error due to the incompatibility of some functions.


This program is free software: you can redistribute and/or modify it under the terms of the GNU lesser General Public License, either version 3, or any later version. This program is distributed in the hope that it will be useful, but without any warranty. 


(c) Kaveh Fathian, Kasra Khosoussi, Yulun Tian, Parker Lusk, Jonathan How. 2020.


