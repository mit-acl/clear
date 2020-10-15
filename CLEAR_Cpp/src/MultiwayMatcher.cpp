#include "clear/MultiwayMatcher.hpp"
#include "clear/utils/blockSVD.hpp"
#include "clear/Hungarian.h"

#include <cassert>
#include <fstream>
#include <Eigen/SVD>
#include <Eigen/SparseLU>
#include <ctime>
#include <ratio>
#include <chrono>
#include <utility>

using std::vector;
using namespace std::chrono;
using Eigen::MatrixXf;

void MultiwayMatcher::initialize(const Eigen::MatrixXf &A, vector<unsigned> numSmp) {
  A_sp = A.sparseView();
  numSmp_ = std::move(numSmp);

  // compute cumsum_
  cumSum_.resize(numSmp_.size(), 0);
  std::partial_sum(numSmp_.begin(), numSmp_.end(), cumSum_.begin());
  assert(cumSum_.back() == A.rows());

  // compute other matrices needed
  construct_D();
  construct_L();
  construct_Lnrm();
}

void MultiwayMatcher::estimate_universe_size() {
  // singular value decomposition on Lnrm_
  // Eigen::JacobiSVD<MatrixXf> svd(Lnrm_, Eigen::ComputeFullU | Eigen::ComputeFullV);
  // Vl_ = svd.matrixV();
  // sl_ = svd.singularValues(); // a column vector of singular values in decreasing order

  blockSVD(MatrixXf(A_sp), Lnrm_, Vl_, sl_);

  m_ = 0;
  for (unsigned i = 0; i < sl_.rows(); ++i) {
    if (sl_(i) < thresh_) m_++;
  }

  vector<unsigned>::iterator max_iterator;
  max_iterator = std::max_element(numSmp_.begin(), numSmp_.end());
  // Minimum # of objects must not be less than max # of samples
  m_ = std::max(*max_iterator, m_);

  fused_counts_.resize(m_, 0);
}

void MultiwayMatcher::CLEAR() {
  // runtime analysis
  high_resolution_clock::time_point t1, t2;
  duration<double, std::milli> elapsed_time;

  t1 = high_resolution_clock::now();
  estimate_universe_size();
  t2 = high_resolution_clock::now();
  elapsed_time = t2 - t1;


  // recover embedding matrix
  N_ = Vl_.block(0, Vl_.cols() - m_, Vl_.rows(), m_);
  assert(N_.rows() == Vl_.rows());
  assert(N_.cols() == m_);

  // L2 normalize each row
  for (unsigned i = 0; i < N_.rows(); ++i) {
    N_.row(i) = N_.row(i) / N_.row(i).norm();
  }

  // find cluster centers (LU)
  // t1 = high_resolution_clock::now();
  // Eigen::FullPivLU<MatrixXf> LUsolver(N_);
  // C_ = LUsolver.permutationP() * N_;
  // C_ = C_.block(0, 0, m_, m_); // each row is a cluster center
  // t2 = high_resolution_clock::now();
  // elapsed_time = t2-t1;
  // if(verbose_) ROS_INFO_STREAM("LU elapsed time: " << (float) elapsed_time.count() / 1000.0 << " seconds.");

  // find cluster centers (greedy)
  t1 = high_resolution_clock::now();
  C_ = MatrixXf::Zero(m_, m_);
  vector<bool> is_pivot(N_.rows(), false);
  vector<unsigned> pivots;
  C_.row(0) = N_.row(0);
  is_pivot[0] = true;
  pivots.push_back(0);
  MatrixXf X = N_ * N_.transpose();
  X = X.array().abs().matrix(); // compute coefficient-wise absolute values
  MatrixXf scores = MatrixXf::Zero(N_.rows(), 1); // initialize score vector
  for (unsigned k = 1; k < m_; ++k) {
    // incremental update to scores
    scores = scores + X.col(pivots[k - 1]);
    // find k-th cluster center
    double min_score = N_.rows();
    int min_idx = -1;
    // find row with best score
    for (unsigned i = 0; i < N_.rows(); ++i) {
      if (is_pivot[i]) continue;
      if (scores(i) < min_score) {
        min_score = scores(i);
        min_idx = i;
      }
    }
    assert(min_idx >= 0);
    C_.row(k) = N_.row(min_idx);
    is_pivot[min_idx] = true;
    pivots.push_back(min_idx);
  }
  t2 = high_resolution_clock::now();
  elapsed_time = t2 - t1;


  // scores based on dot product
  MatrixXf F = -N_ * C_.transpose();

  assignments_.resize(N_.rows(), -1);

  // go through each agent
  t1 = high_resolution_clock::now();
  for (unsigned agent = 0; agent < numSmp_.size(); ++agent) {
    unsigned size = numSmp_[agent];
    unsigned start_idx = 0;
    if (agent > 0) start_idx = cumSum_[agent - 1];
    MatrixXf cost = F.block(start_idx, 0, size, m_);

    // convert from Matrix to std::vector (TODO: improve)
    vector<vector<double>> costMatrix;
    for (unsigned i = 0; i < size; ++i) {
      // copy row i
      vector<double> row;
      for (unsigned j = 0; j < m_; ++j) {
        row.push_back(cost(i, j));
      }
      costMatrix.push_back(row);
    }

    // assign to universe using Hungarian
    vector<int> a;
    HungarianAlgorithm Hungarian;
    Hungarian.Solve(costMatrix, a);

    // copy results to assignments vector
    for (unsigned i = 0; i < size; ++i) {
      assert(a[i] >= 0);
      assignments_[start_idx + i] = a[i];
      fused_counts_[a[i]] = fused_counts_[a[i]] + 1;
    }
  }
  t2 = high_resolution_clock::now();
  elapsed_time = t2 - t1;

  // recover lifting permutation
  Y_ = MatrixXf::Zero(N_.rows(), m_);
  // // go through each observation
  for (unsigned i = 0; i < Y_.rows(); ++i) {
    Y_(i, assignments_[i]) = 1;
  }

  // // recover pairwise matches
  X_ = Y_ * Y_.transpose();
}

Eigen::MatrixXf MultiwayMatcher::get_X() const {
  return X_;
}

Eigen::MatrixXf MultiwayMatcher::get_Y() const {
  return Y_;
}

vector<int> MultiwayMatcher::get_assignments() const {
  return assignments_;
}

vector<unsigned> MultiwayMatcher::get_fused_counts() const {
  return fused_counts_;
}

void MultiwayMatcher::construct_D() {
  // D_ = MatrixXf::Zero(A_.rows(), A_.cols());
  // for (unsigned i = 0; i < A_.rows(); ++i){
  // 	D_(i,i) = A_.row(i).sum();
  // }

  D_sp.resize(A_sp.rows(), A_sp.cols());
  D_sp.reserve(A_sp.rows());
  for (int i = 0; i < A_sp.rows(); ++i) {
    D_sp.insert(i, i) = A_sp.col(i).sum();
  }
}

void MultiwayMatcher::construct_L() {
  // L_ = D_ - A_;
  L_sp = D_sp - A_sp;
  // make symmetric
  // L_ = (L_ + L_.transpose())/2.0;
}

void MultiwayMatcher::construct_Lnrm() {
  // MatrixXf N = D_;
  // for (unsigned i = 0; i < D_.rows(); ++i){
  // 	double degree = D_(i,i);
  // 	assert(degree >= 0);
  // 	N(i,i) = 1 / std::sqrt((degree + 1)); // plus one to avoid dividing by zeros
  // }
  // Lnrm_ = N * L_ * N;


  Eigen::SparseMatrix<float> N_sp;
  N_sp.resize(L_sp.rows(), L_sp.cols());
  N_sp.reserve(L_sp.rows());
  for (int i = 0; i < D_sp.rows(); ++i) {
    N_sp.insert(i, i) = 1 / std::sqrt((D_sp.coeffRef(i, i) + 1)); // plus one to avoid dividing by zeros
  }
  Lnrm_sp = N_sp * L_sp * N_sp;
  Lnrm_ = MatrixXf(Lnrm_sp);
}

unsigned int MultiwayMatcher::get_universe_size() const {
  return m_;
}
