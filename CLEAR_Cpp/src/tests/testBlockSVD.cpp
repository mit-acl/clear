#include <clear/utils/blockSVD.hpp>
#include <iostream>
#include <cassert>
#include <random>
#include <time.h>
#include <ctime>
#include <ratio>
#include <chrono>

using namespace std;
using namespace std::chrono;

void test1(){
	vector< vector<double> > Adj = { { 0,1,0,0 }, 
								     { 1,0,0,0 }, 
								     { 0,0,0,1 }, 
								     { 0,0,1,0 } };
	unsigned n = Adj.size();
	assert(n == Adj[0].size());

    Eigen::MatrixXf A, D, L, Lnrm, Vl, sl;
    A = MatrixXf::Zero(n, n);
    for (unsigned i = 0; i < n; ++i){
    	for(unsigned j = 0; j < n; ++j){
    		A(i,j) = Adj[i][j];
    	}
    }
    D = MatrixXf::Zero(A.rows(), A.cols());
	for (unsigned i = 0; i < A.rows(); ++i){
		D(i,i) = A.row(i).sum();
	}
	L = D - A;
	// make symmetric
	L = (L + L.transpose()) / 2.0;
	MatrixXf N = D;
	for (unsigned i = 0; i < D.rows(); ++i){
		double degree = D(i,i);
		assert(degree >= 0);
		N(i,i) = 1 / std::sqrt((degree + 1)); // plus one to avoid dividing by zeros
	}
	Lnrm = N * L * N;

    
	// Compute reference solution
	Eigen::JacobiSVD<MatrixXf> svd(Lnrm, Eigen::ComputeFullU | Eigen::ComputeFullV);
	MatrixXf Vl_ref = svd.matrixV();
	MatrixXf sl_ref = svd.singularValues(); // a column vector of singular values in decreasing order
    
    blockSVD(A, Lnrm, Vl, sl);

    MatrixXf sl_diff = sl - sl_ref;
    MatrixXf Vl_diff = Vl - Vl_ref;
    assert(sl_diff.norm() < 0.001);
    assert(Vl_diff.norm() < 0.001);
    cout << "[testBlockSVD] test1 passed." << endl;
}

void testRandomGraph(){
	unsigned n = 1000;
	float p = 0.001; // probability that any two vertices are connected
	std::random_device rd;
    std::mt19937 gen(rd());
    std::bernoulli_distribution distribution(p);


	Eigen::MatrixXf A, D, L, Lnrm, Vl, sl;
    A = MatrixXf::Zero(n, n);
    for (unsigned i = 0; i < n; ++i){
    	for(unsigned j = i+1; j < n; ++j){
    		if (distribution(gen)){
    			A(i,j) = 1;
    			A(j,i) = 1;
    		}
    	}
    }

    D = MatrixXf::Zero(A.rows(), A.cols());
	for (unsigned i = 0; i < A.rows(); ++i){
		D(i,i) = A.row(i).sum();
	}
	L = D - A;
	// make symmetric
	L = (L + L.transpose()) / 2.0;
	MatrixXf N = D;
	for (unsigned i = 0; i < D.rows(); ++i){
		double degree = D(i,i);
		assert(degree >= 0);
		N(i,i) = 1 / std::sqrt((degree + 1)); // plus one to avoid dividing by zeros
	}
	Lnrm = N * L * N;

	// Compute reference solution
	high_resolution_clock::time_point t1 = high_resolution_clock::now();
	Eigen::JacobiSVD<MatrixXf> svd(Lnrm, Eigen::ComputeFullU | Eigen::ComputeFullV);
	MatrixXf Vl_ref = svd.matrixV();
	MatrixXf sl_ref = svd.singularValues(); // a column vector of singular values in decreasing order
	high_resolution_clock::time_point t2 = high_resolution_clock::now();
	duration<double, std::milli> time_span = t2 - t1;

   	high_resolution_clock::time_point t3 = high_resolution_clock::now();
    blockSVD(A, Lnrm, Vl, sl);
    high_resolution_clock::time_point t4 = high_resolution_clock::now();
    duration<double, std::milli> time_span2 = t4 - t3;
	std::cout << "I am " << (float) time_span.count() / (float) time_span2.count() << " times faster." << endl;

    // Currently only verify RMSE on singular values
    MatrixXf sl_diff = sl - sl_ref;
    MatrixXf Vl_diff = Vl - Vl_ref;
    double sl_RMSE = sqrt(sl_diff.squaredNorm() / n );
    assert(sl_RMSE < 0.001);
} 

int main(void)
{
    
	// test1();
	for (unsigned trial = 0 ; trial < 100; ++trial){
		testRandomGraph();	
	}

	return 0;
}