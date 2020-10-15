#include <clear/MyGraph.hpp>

using namespace std;
using Eigen::MatrixXf;
using Eigen::MatrixXi;

MyGraph::MyGraph(Eigen::MatrixXf A){
	unsigned n = A.rows();
	A_ = MatrixXi::Zero(n,n);
	for (unsigned i = 0; i < n ; ++i){
		for(unsigned j = 0; j < n; ++j){
			if(A(i,j) > 0.5){
				A_(i,j) = 1;
			}else{
				A_(i,j) = 0;
			}
		}
	}
}


MyGraph::~MyGraph(){}


void MyGraph::findConnComps(){
	MatrixXi Adj = A_;
	unsigned n = Adj.rows();
	assert(n > 0);

	ConnComps.clear();
	
	// initialize visited list
	vector<bool> visited(n, false);
	
	
	for (unsigned start = 0; start < n; ++ start){

		if(!visited[start]){
			// perform BFS from start
			vector<unsigned> Comp;
			queue<unsigned> frontier;

			frontier.push(start);
			visited[start] = true;

			while(!frontier.empty()){
				unsigned idx = frontier.front();
				frontier.pop();
				Comp.push_back(idx);

				for (unsigned jdx = 0; jdx < n; ++jdx){
					if (!visited[jdx] && Adj(idx,jdx) == 1){
						visited[jdx] = true;
						frontier.push(jdx);
					}
				}
			}


			ConnComps.push_back(Comp);
		}
	}
}

unsigned MyGraph::getNumConnComps(){
	return ConnComps.size();
}

vector<vector<unsigned>> MyGraph::getConnComps(){
	return ConnComps;
}