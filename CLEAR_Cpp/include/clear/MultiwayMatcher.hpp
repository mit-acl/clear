#pragma once

#include <vector>
#include <algorithm>
#include <Eigen/Core>
#include <Eigen/Dense>
#include <Eigen/SparseCore>
#include <unsupported/Eigen/MatrixFunctions>

using std::vector;
using Eigen::MatrixXf;

class MultiwayMatcher {
public:
  MultiwayMatcher() = default;
  ~MultiwayMatcher() = default;

  void initialize(Eigen::MatrixXf const &A, vector<unsigned> numSmp);

  void estimate_universe_size();
  void CLEAR();

  Eigen::MatrixXf get_X() const;
  Eigen::MatrixXf get_Y() const;
  std::vector<int> get_assignments() const;
  std::vector<unsigned int> get_fused_counts() const;
  unsigned int get_universe_size() const;

private:
  void construct_D();
  void construct_L();
  void construct_Lnrm();

  vector<unsigned> numSmp_;
  vector<unsigned> cumSum_;

  Eigen::SparseMatrix<float> A_sp;
  Eigen::SparseMatrix<float> D_sp;
  Eigen::SparseMatrix<float> L_sp;
  Eigen::SparseMatrix<float> Lnrm_sp;


  // MatrixXf A_;
  // MatrixXf D_;
  // MatrixXf L_;
  MatrixXf Lnrm_; // Normalized Laplacian
  MatrixXf sl_; // vector of singular values of Lnrm_ (decreasing order)
  MatrixXf Vl_; // right singular vectors of Lnrm_
  MatrixXf N_; // embedding matrix (CLEAR)
  MatrixXf C_; // cluster centers (CLEAR)
  MatrixXf Y_; // lifting permutation (CLEAR)
  MatrixXf X_; // optimized pairwise permutations (CLEAR)

  unsigned m_ = 0; // estimated size of the universe
  vector<int> assignments_; // assignment of each local observation to the universe
  vector<unsigned> fused_counts_; // observation count of each global object

  // threshold for estimating universe size
  double thresh_ = 0.50;
};