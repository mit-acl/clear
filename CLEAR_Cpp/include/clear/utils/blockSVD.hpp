#ifndef BLOCKSVD_H
#define BLOCKSVD_H

#include <clear/MyGraph.hpp>
#include <iostream>
#include <vector>
#include <numeric>
#include <queue>
#include <algorithm>
#include <Eigen/Core>
#include <Eigen/Dense>
#include <unsupported/Eigen/MatrixFunctions>

using namespace std;
using Eigen::MatrixXf;
using Eigen::MatrixXi;

inline void blockSVD(Eigen::MatrixXf A, Eigen::MatrixXf Lnrm, Eigen::MatrixXf& Vl, Eigen::MatrixXf& sl)
{
	MyGraph G(A);
	unsigned n = A.rows();
	G.findConnComps();
	vector<vector<unsigned>> ConnComps = G.getConnComps();

	MatrixXf V;
	V = MatrixXf::Zero(n,n);
	vector<double> s(n, 0.0);
	// cout << "Number of connected components: " << ConnComps.size() << endl;

	for (unsigned cc = 0; cc < ConnComps.size(); ++cc){
		vector<unsigned> Comp = ConnComps[cc];
		unsigned CompSize = Comp.size();
		MatrixXf Lc;
		Lc = MatrixXf::Zero(CompSize, CompSize);
		for (unsigned i = 0; i < CompSize; ++i){
			for (unsigned j = 0; j < CompSize; ++j){
				Lc(i,j) = Lnrm(Comp[i], Comp[j]);
			}
		}
		// Compute SVD of this block
		Eigen::JacobiSVD<MatrixXf> svd(Lc, Eigen::ComputeFullU | Eigen::ComputeFullV);
		MatrixXf Vc = svd.matrixV();
		MatrixXf sc = svd.singularValues(); // a column vector of singular values in decreasing order

		for (unsigned i = 0; i < CompSize; ++i){
			for (unsigned j = 0; j < CompSize; ++j){
				V(Comp[i], Comp[j]) = Vc(i,j);
			}
		}
		for (unsigned i = 0; i < CompSize; ++i){
			s[Comp[i]] = sc(i);
		}
	}

	// sort based on singular values (in decreasing order)
	vector<size_t> sorted_idx(s.size());
	std::iota(sorted_idx.begin(), sorted_idx.end(), 0);
	std::sort(sorted_idx.begin(), sorted_idx.end(),
	       [&s](size_t i1, size_t i2) {return s[i1] > s[i2];});

	sl = MatrixXf::Zero(n,1);
	Vl = MatrixXf::Zero(n,n);

	// rearrange based on sorted index
	for (unsigned i = 0 ; i < n ; ++i){
		unsigned k = sorted_idx[i];
		sl(i) = s[k];
		Vl.col(i) = V.col(k);
	}
}


#endif 