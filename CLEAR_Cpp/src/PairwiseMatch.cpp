#include <clear/PairwiseMatch.hpp>
#include <cassert>
#include <Eigen/Core>
#include <Eigen/Dense>

using std::vector;
using std::pair;
using Eigen::MatrixXd;
PairwiseMatch::PairwiseMatch(){}
	
PairwiseMatch::~PairwiseMatch(){}

void PairwiseMatch::set_KF_pair(ForestKeyframe* KF1, ForestKeyframe* KF2){
	KF1_ = KF1;
	KF2_ = KF2;
}

void PairwiseMatch::set_matches(vector<pair<int, int>>& matches){
	matches_ = matches;	
}

ForestKeyframe* PairwiseMatch::get_first_KF(){
	return KF1_;
}

ForestKeyframe* PairwiseMatch::get_second_KF(){
	return KF2_;
}

unsigned PairwiseMatch::get_num_matches(){
	return matches_.size();
}

void PairwiseMatch::get_matches(vector<pair<int, int>>& matches){
	matches = matches_;
}

void PairwiseMatch::get_permutation_matrix(Eigen::MatrixXd& P){
	int num_rows = KF1_->get_size();
	int num_cols = KF2_->get_size();
	P.resize(num_rows, num_cols);
	P.block(0,0,num_rows,num_cols) = MatrixXd::Zero(num_rows, num_cols);

	for (unsigned k = 0 ; k < matches_.size(); ++k){
		pair<int,int> p = matches_[k];
		int from = std::get<0>(p);
		int to = std::get<1>(p);
		P(from, to) = 1.0;
	}
}

bool PairwiseMatch::get_transform(isam::Pose2d& transform){
	unsigned num_matches = get_num_matches();
	if (num_matches < 2) return false;
	
	vector<double> x1, y1, x2, y2; 
	KF1_->get_features_x(x1);
	KF1_->get_features_y(y1);
	KF2_->get_features_x(x2);
	KF2_->get_features_y(y2);

	// get the corresponding points
	vector<double> xc1, yc1, xc2, yc2;
	for (unsigned idx = 0; idx < matches_.size(); ++idx) {
		int i1 = matches_[idx].first;
		int i2 = matches_[idx].second;
		xc1.push_back(x1[i1]);
		yc1.push_back(y1[i1]);
		xc2.push_back(x2[i2]);
		yc2.push_back(y2[i2]);
	}

	MatrixXd X(2, num_matches);
	MatrixXd Y(2, num_matches);
	MatrixXd meanX(2, 1);
	MatrixXd meanY(2, 1);
	meanX(0,0) = std::accumulate(xc1.begin(), xc1.end(), 0.0f) / (double)num_matches;
	meanX(1,0) = std::accumulate(yc1.begin(), yc1.end(), 0.0f) / (double)num_matches;
	meanY(0,0) = std::accumulate(xc2.begin(), xc2.end(), 0.0f) / (double)num_matches;
	meanY(1,0) = std::accumulate(yc2.begin(), yc2.end(), 0.0f) / (double)num_matches;

	// centering 
	for (unsigned idx = 0; idx < num_matches; ++idx) {
		int i1 = matches_[idx].first;
		int i2 = matches_[idx].second;
		X(0, idx) = x1[i1] - meanX(0,0);
		X(1, idx) = y1[i1] - meanX(1,0);
		Y(0, idx) = x2[i2] - meanY(0,0);
		Y(1, idx) = y2[i2] - meanY(1,0);
  	}

  	// compute SVD
	MatrixXd S = X * Y.transpose();
	Eigen::JacobiSVD<Eigen::MatrixXd> svd(S,  Eigen::ComputeThinU|Eigen::ComputeThinV);
	MatrixXd product = svd.matrixV() * (svd.matrixU().transpose());
	MatrixXd I = MatrixXd::Identity(2, 2);
	I(1,1) = product.determinant(); // correct determinant
	MatrixXd R = svd.matrixV() * I * (svd.matrixU().transpose());
	MatrixXd T = meanY - R * meanX;

	// sanity check that R is a valid solution
	MatrixXd residual = R.transpose() * R - MatrixXd::Identity(2,2);
	double residual_norm = residual.squaredNorm();
	assert(residual_norm < 0.0001);
	assert(abs(1-R.determinant()) < 0.001);

	transform.set_x(T(0,0));
	transform.set_y(T(1,0));
	if(R(0,0) > 1){
		transform.set_t(0.0);
	}
	else if(R(0,0) < -1){
		transform.set_t(3.1415926);
	}
	else{
		transform.set_t(atan2(R(1,0), R(0,0)));
	}
	return true;
}