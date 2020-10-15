#ifndef MYGRAPH_H
#define MYGRAPH_H

#include <vector>
#include <queue>
#include <algorithm>
#include <Eigen/Core>
#include <Eigen/Dense>
#include <unsupported/Eigen/MatrixFunctions>

using std::vector;
using Eigen::MatrixXf;

class MyGraph{

public:
	MyGraph(Eigen::MatrixXf A);
	~MyGraph();
	void findConnComps();
	unsigned getNumConnComps();
	vector<vector<unsigned>> getConnComps();

private:
	

	Eigen::MatrixXi A_;
	vector<vector<unsigned>> ConnComps; // each vector is a connected component	

};



#endif