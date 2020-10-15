#include <iostream>
#include <vector>
#include <Eigen/Core>
#include <Eigen/Dense>
#include <cassert>
#include <clear/MyGraph.hpp>


using namespace std;
using Eigen::MatrixXf;

void test1(){
	vector< vector<double> > Adj = { { 0,1,0,0 }, 
								     { 1,0,0,0 }, 
								     { 0,0,0,1 }, 
								     { 0,0,1,0 } };
	unsigned n = Adj.size();
	assert(n == Adj[0].size());

    Eigen::MatrixXf A;
    A = MatrixXf::Zero(n, n);
    for (unsigned i = 0; i < n; ++i){
    	for(unsigned j = 0; j < n; ++j){
    		A(i,j) = Adj[i][j];
    	}
    }


    cout << "Input adjacency matrix: " << endl;
    cout << A << endl;


	MyGraph G(A);
	G.findConnComps();
	vector<vector<unsigned>> ConnComps = G.getConnComps();
	for (unsigned k = 0; k < ConnComps.size(); ++k){
		cout << "Connected components " << k << ": ";
		for (unsigned i =0 ; i < ConnComps[k].size(); ++i){
			cout << ConnComps[k][i] << " ";
		}
		cout << endl;
	}

	assert(G.getNumConnComps() == 2);
	cout << "[testMyGraph] Passed test 1." << endl;
}


void test2(){
	vector< vector<double> > Adj = { { 0,0,1,0,1 }, 
								     { 0,0,0,0,0 }, 
								     { 1,0,0,0,1 }, 
								     { 0,0,0,0,0 },
								     { 1,0,1,0,0 }};
	unsigned n = Adj.size();
	assert(n == Adj[0].size());

    Eigen::MatrixXf A;
    A = MatrixXf::Zero(n, n);
    for (unsigned i = 0; i < n; ++i){
    	for(unsigned j = 0; j < n; ++j){
    		A(i,j) = Adj[i][j];
    	}
    }


    cout << "Input adjacency matrix: " << endl;
    cout << A << endl;


	MyGraph G(A);
	G.findConnComps();
	vector<vector<unsigned>> ConnComps = G.getConnComps();
	for (unsigned k = 0; k < ConnComps.size(); ++k){
		cout << "Connected components " << k << ": ";
		for (unsigned i =0 ; i < ConnComps[k].size(); ++i){
			cout << ConnComps[k][i] << " ";
		}
		cout << endl;
	}

	assert(G.getNumConnComps() == 3);
	cout << "[testMyGraph] Passed test 2." << endl;
}


int main(void)
{
    
	test1();
	test2();
	

	return 0;
}