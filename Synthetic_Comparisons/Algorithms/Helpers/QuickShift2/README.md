# Introduction
This directory contains the code for the QuickShift [1] and QuickMatch [2] algorithms. While the de-facto reference implementation of QuickShift for the algorithm as originally described in [1] is the one in VLFeat [3], that implementation is specialized to image segmentation. The implementation provided here is geared toward more general clustering applications, and contains many extensions not given in the original paper. QuickMatch is an algorithm that follows many of the steps of QuickShift, but solves the matching problem instead of the clustering problem. In the code, it is referred to as quickshit_matching.

# Tests
The code contains several functions that serve both to check if your copy is functional and as examples on how to use the main functions; these functions contain the string "_test" in their name.
The primary files are quickshift_test.m and quickshift_matching_test.m.

# Contact info
The main author of the code is Roberto Tron. Please send questions to tron@bu.edu.

# References
[1] A. Vedaldi and S. Soatto. Quick shift and kernel methods for mode seeking. In IEEE European Conference on Computer Vision, pages 705–718. 2008.
[2] R. Tron and X. Zhou. Fast Multi-Image Matching via Density-Based Clustering. 
[3] http://www.vlfeat.org/

# License

QuickMatch is released under a [GPLv3 license](License-gpl.txt).

For a closed-source version of QuickMatch for commercial purposes, please contact the authors: tron@bu.edu

# Prerequisites/ Dependencies
We have tested the library in MatLab 2016, but it should work in other MatLab versions easily. A powerful computer (e.g. i7) will ensure fastest performance.

# Acknoledgements
This code has been developed under the support of the National Science Foundation grant "Robust, Scalable, Distributed Semantic Mapping for Search-and-Rescue and Manufacturing Co-Robots" (Award number 1734454).
Disclaimer: Any opinions, findings, and conclusions or recommendations expressed in this material are those of the author(s) and do not necessarily reflect the views of the National Science Foundation.


