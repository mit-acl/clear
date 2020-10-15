// Wrapper class for dynamic means clustering

#pragma once

#include <vector>
#include <dynmeans/dynmeans.hpp>
#include <Eigen/Core>
#include <Eigen/Dense>

using std::vector;
using Eigen::Vector2d;
class DynmeansCluster{

public:
	DynmeansCluster();
	~DynmeansCluster();

	void reset();
	void cluster(vector<double> xs, vector<double> ys);
	void top_k(unsigned k);

	unsigned get_num_clusters();
	void get_cluster_size(vector<unsigned>& cluster_size);
	void get_cluster_xs(vector<vector<double>>& cluster_xs);
	void get_cluster_ys(vector<vector<double>>& cluster_ys);
	void get_cluster_centers(vector<Vector2d>& cluster_centers);

private:
	DynMeans<Vector2d>* dynmean_;
	int n_restarts_ = 2;
	double lambda_dynm = 0.4;
	double T_Q_dynm = 40.0;
	double K_tau = 1.01; // Must be > 1!
	bool init_ = false;

	vector<Vector2d> cluster_centers_;
	vector<vector<double>> cluster_xs_;
	vector<vector<double>> cluster_ys_;
	vector<unsigned> cluster_size_;
};