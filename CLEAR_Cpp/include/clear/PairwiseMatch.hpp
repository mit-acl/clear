#pragma once

#include <vector>
#include <Eigen/Core>
#include <Eigen/Dense>
#include <isam/isam.h>


using std::vector;
using std::pair;
using Eigen::MatrixXd;
class PairwiseMatch{
public:
	PairwiseMatch();
	~PairwiseMatch();
	void set_KF_pair(ForestKeyframe* KF1, ForestKeyframe* KF2);
	void set_matches(vector<pair<int, int>>& matches);
	ForestKeyframe* get_first_KF();
	ForestKeyframe* get_second_KF();
	unsigned get_num_matches();
	void get_matches(vector<pair<int, int>>& matches);
	void get_permutation_matrix(Eigen::MatrixXd& P);
	bool get_transform(isam::Pose2d& transform);
private:
	ForestKeyframe* KF1_;
	ForestKeyframe* KF2_;
	vector<pair<int, int>> matches_;
};