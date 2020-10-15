#pragma once

#include <vector>
#include <isam/isam.h>
#include <Eigen/Core>
#include <Eigen/Dense>
#include <clear/DynmeansCluster.hpp>

using std::vector;
using Eigen::MatrixXd;
using Eigen::Vector3f;
using Eigen::Vector2d;
using namespace isam;

class FlirtSubmap{
public:
	FlirtSubmap(unsigned agent_id, unsigned submap_id, isam::Pose2d origin);
	// Copy constructor
	FlirtSubmap(FlirtSubmap* map);
	~FlirtSubmap();
	void add_feature(double x, double y);
	void get_feature_x(vector<double>& px);
	void get_feature_y(vector<double>& py);
	void get_origin(isam::Pose2d& origin);
	void set_origin(isam::Pose2d& origin);
	// use dynamic means to clusterinf raw points and and only keep the top "k" clusters
	void cluster_features(unsigned k);
	unsigned get_num_features();
	unsigned get_agent_id();
	unsigned get_submap_id();
private:
	unsigned agent_id_;
	unsigned submap_id_;
	Pose2d origin_; // initial origin estimated by EKF
	Pose2d origin_optimized_; // optimized origin after iSAM
	vector<double> xs; // x coordinates of all features
	vector<double> ys; // y coordinates of all features
	DynmeansCluster* dmCluster; // dynamic means clustering
};