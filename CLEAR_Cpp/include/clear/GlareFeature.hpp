#pragma once

// Includes
#include <Eigen/Dense>
#include <Eigen/Core>

#include <cmath>
#include <cassert>
#include <vector>
// #include <utility>
#include <algorithm>
#include <iostream>

// Declare namespaces
// using Eigen::ArrayXd;
// using Eigen::ArrayXXd;
// using Eigen::ArrayXf;
using Eigen::VectorXf;
using Eigen::ArrayXXf;
using std::max;
using std::min;

// const float PI = 3.14159265359;

class GlareFeature {
public:
  GlareFeature(int n_theta=16, int n_rad=50, float rad_max=10.0, float std_dev_rad=0.5,
               float std_dev_theta=0.2, int n_sigma=3);

  ArrayXXf GetGlare(std::vector<float> x, std::vector<float> y);

private:
  float normal_pdf(float rad, float theta, float rad_mu, float theta_mu);
  int theta_to_index(float theta);
  float index_to_theta(int ind);
  int rad_to_index(float rad);
  float index_to_rad(int ind);

  int n_theta_;
  int n_rad_;
  float rad_max_;
  float std_dev_rad_;
  float std_dev_theta_;
  int n_sigma_;
  float d_theta_;
  float d_rad_;
  int d_index_rad_;
  int d_index_theta_;
};

float GlarotDistance(ArrayXXf g1, ArrayXXf g2) {
  float min_dist = 100.0f;
  int n_theta = g1.cols();
  for (int idx = 0; idx < n_theta; ++idx) {
    float dist = 0.0f;
    for (int jdx =0; jdx < n_theta; ++jdx) {
      VectorXf diff = g1.col(jdx) - g2.col((jdx + idx) % n_theta);
      // dist += (g1.col(jdx) - g2.col((jdx + idx) % n_theta)).lpNorm<1>(); 
      dist += diff.lpNorm<1>();
    }
    if (dist < min_dist) {
      min_dist = dist;
    }
  }
  return min_dist;
}

inline float dist(float x1, float y1, float x2, float y2) {
  return sqrt((x1 - x2)*(x1 - x2) + (y1 - y2)*(y1 - y2));
}

inline float angle_dist(float x1, float y1, float x2, float y2) {
  float d1 = atan2(y2 - y1, x2 - x1);
  float d2 = atan2(y1 - y2, x1 - x2);
  // TODO: consider if the abs is correct? 
  return fabs(max(d1, d2));
}

inline int true_mod(int n, int m) {
  return ((n % m) + m) % m;
}

float GlareFeature::normal_pdf(float rad, float theta, float rad_mu, float theta_mu) {

  float dx = (rad-rad_mu)*(rad-rad_mu)/(std_dev_rad_*std_dev_rad_) + (theta-theta_mu)*(theta-theta_mu)/(std_dev_theta_*std_dev_theta_); 
  return exp(-0.5f*dx);
}

int GlareFeature::theta_to_index(float theta) {
  return true_mod((int)round(theta/d_theta_ + 0.5), n_theta_);
}

float GlareFeature::index_to_theta(int ind) {
  return ind*d_theta_ + d_theta_/2.0;
}

int GlareFeature::rad_to_index(float rad) {
  return min((int) round(rad/d_rad_ + 0.5), n_rad_ - 1);
}

float GlareFeature::index_to_rad(int ind) {
  return ind*d_rad_ + d_rad_/2.0;
}

GlareFeature::GlareFeature(int n_theta, int n_rad, float rad_max, float std_dev_rad, 
    float std_dev_theta, int n_sigma) 
: n_theta_(n_theta),
  n_rad_(n_rad),
  rad_max_(rad_max),
  std_dev_rad_(std_dev_rad),
  std_dev_theta_(std_dev_theta),
  n_sigma_(n_sigma),
  d_theta_(3.14159265359/n_theta),
  d_rad_(rad_max/n_rad)
{
  d_index_rad_ = ceil(n_sigma_*std_dev_rad_/d_rad_);
  d_index_theta_ = ceil(n_sigma_*std_dev_theta_/d_theta_);
  // std::cout << "n_theta_: "<< n_theta_ << std::endl;
}

ArrayXXf GlareFeature::GetGlare(std::vector<float> x, std::vector<float> y) {
  ArrayXXf glare = ArrayXXf::Zero(n_rad_, n_theta_);
  assert(x.size() == y.size());
  int n_points = x.size();
  for (int idx = 0; idx < n_points; ++idx) {
    for (int jdx = idx+1; jdx < n_points; ++jdx) {
      float rad_dist = dist(x[idx], y[idx], x[jdx], y[jdx]);
      float theta_dist = angle_dist(x[idx], y[idx], x[jdx], y[jdx]);
      // std::cout << "Rad dist: " << rad_dist << "/" << rad_max_ << std::endl;
      if (rad_dist > rad_max_) continue;
      // Define truncated domain for Gaussian sampling

      if (std_dev_rad_ < 0.05f) {
        int idr = rad_to_index(rad_dist);
        int jdt = theta_to_index(theta_dist);
        // std::cout << "Theta: " << theta_dist << std::endl;
        // std::cout << "Index pre-mod: " << (int)round(theta_dist/d_theta_ + 0.5) << std::endl;
        // std::cout << "Index: " << jdt << std::endl;

        glare(idr, true_mod(jdt, n_theta_)) = glare(idr, true_mod(jdt, n_theta_)) + 1.0f;
      } else {

        int rad_min_ind = max(0, rad_to_index(rad_dist) - d_index_rad_);
        int rad_max_ind = min(n_rad_ - 1, rad_to_index(rad_dist) + d_index_rad_);
        int theta_min_ind = (theta_to_index(theta_dist) - d_index_theta_);
        int theta_max_ind = (theta_to_index(theta_dist) + d_index_theta_);

        // std::cout << "Rad min, max: " << rad_min_ind << ", " << rad_max_ind << std::endl;
        // std::cout << "Theta min, max: " << theta_min_ind << ", " << theta_max_ind << std::endl;
        for (int idr = rad_min_ind; idr <= rad_max_ind; ++idr) {
          float rad_i = index_to_rad(idr);
          for (int jdt = theta_min_ind; jdt <= theta_max_ind; ++jdt) {
            float theta_j = index_to_theta(jdt % n_theta_);
            glare(idr, true_mod(jdt, n_theta_)) = glare(idr, true_mod(jdt, n_theta_)) + normal_pdf(rad_i, theta_j, rad_dist, theta_dist);
            // std::cout << "Rad: " << rad_i << std::endl;
            // std::cout << "Theta: " << theta_j << std::endl;
            // std::cout << "Norm: " << normal_pdf(rad_i, theta_j, rad_dist, theta_dist) << std::endl;

          }
        }
      }
    }
  }
  glare = glare/glare.sum();
  return glare;
}