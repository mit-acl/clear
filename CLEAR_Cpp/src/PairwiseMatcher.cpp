#include <clear/PairwiseMatcher.hpp>
#include <ros/console.h>
// #include <falkolib/Feature/Keypoint.h>
// #include <falkolib/Feature/Descriptor.h>
// #include <falkolib/Matching/CCDAMatcher.h>
#include "clear/Hungarian.h"

using std::vector;
using std::pair;
using Eigen::Vector3f;
using Eigen::MatrixXf;
// using falkolib::Keypoint;
// using falkolib::Descriptor;
// using falkolib::CCDAMatcher;
// using falkolib::Point2d;

PairwiseMatcher::PairwiseMatcher(){}

PairwiseMatcher::~PairwiseMatcher(){}

void PairwiseMatcher::reset(){
  pc1_.clear();
  pc2_.clear();
  matches_.clear();
}

void PairwiseMatcher::set_nn_dist_tol(double dist_tol){
  nn_dist_tol_ = dist_tol;
}


bool PairwiseMatcher::nn_match(vector<Eigen::Vector3f> pc1, vector<Eigen::Vector3f> pc2){
  reset();
  pc1_ = pc1;
  pc2_ = pc2;


  unsigned N1 = pc1.size();
  unsigned N2 = pc2.size();
  vector<vector<double>> costMatrix;
  for (unsigned i = 0 ; i < N1; ++i){
    vector<double> distances;
    distances.clear();
    for (unsigned j = 0; j < N2; ++ j){
      Vector3f pi = pc1[i];
      Vector3f pj = pc2[j];
      Vector3f pij = pi - pj;
      distances.push_back(pij.norm());
    }
    costMatrix.push_back(distances);
  }

  HungarianAlgorithm HungAlgo;
  vector<int> assignment;
  HungAlgo.Solve(costMatrix, assignment);

  // go through assignment
  for(unsigned i = 0; i < N1; ++i){
    int j = assignment[i];
    if (j >= 0){
      // Hungarian matches i in pc1 with j in pc2
      // check their distance
      if (costMatrix[i][j] < nn_dist_tol_){
        pair<int,int> p = std::make_pair(i, j);
        matches_.push_back(p);
      }
    }
  }

  // ROS_INFO_STREAM("Number of matches: " << matches_.size());

  if(matches_.empty()) return false;
  return true;
}



unsigned PairwiseMatcher::get_num_matches(){
  return matches_.size();
}

void PairwiseMatcher::get_matches(vector<pair<int, int>>& matches){
  matches = matches_;
}

void PairwiseMatcher::get_permutation_matrix(Eigen::MatrixXf& P){
  int num_rows = pc1_.size();
  int num_cols = pc2_.size();
  P.resize(num_rows, num_cols);
  P.block(0,0,num_rows,num_cols) = MatrixXf::Zero(num_rows, num_cols);

  for (unsigned k = 0 ; k < matches_.size(); ++k){
    pair<int,int> p = matches_[k];
    int from = std::get<0>(p);
    int to = std::get<1>(p);
    P(from, to) = 1.0;
  }
}