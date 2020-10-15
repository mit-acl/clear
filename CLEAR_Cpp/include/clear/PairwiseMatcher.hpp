#pragma once
#include <algorithm>
#include <vector>
#include <cmath>
// #include <falkolib/Feature/Keypoint.h>
// #include <Eigen/Core>
#include <Eigen/Dense>
// #include <isam/isam.h>


using std::vector;
using std::pair;
// using falkolib::Keypoint;
using Eigen::Vector3f;
using Eigen::MatrixXf;
// using isam::Pose2d;


/*
Y.T.
This class implements a family of pairwise data assoication algorithms. 
Currently supports:
- nearest neighbor (NN) matching 
- correspondence graph (CG) matching
*/
class PairwiseMatcher{
public:
	PairwiseMatcher();
	~PairwiseMatcher();
	void reset();

	// nearest neighbor (NN) matching
	void set_nn_dist_tol(double dist_tol);
	// NN matching assumes that pc1 and pc2 are in the same coordinate frame!
	bool nn_match(vector<Eigen::Vector3f> pc1, vector<Eigen::Vector3f> pc2);

	
	unsigned get_num_matches();
	void get_matches(vector<pair<int, int>>& matches);
	
	// Convert resulting pairwise matches into a partial permutation matrix
	void get_permutation_matrix(Eigen::MatrixXf& P);

private:
	// NN matching parameters
	double nn_dist_tol_ = 3.5; 
	vector<pair<int, int>> matches_;
	vector<Vector3f> pc1_;
	vector<Vector3f> pc2_;
};