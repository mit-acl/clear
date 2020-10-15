#include <clear/FlirtSubmap.hpp>
#include <ros/console.h>

FlirtSubmap::FlirtSubmap(unsigned agent_id, unsigned submap_id, isam::Pose2d origin){
	agent_id_ = agent_id;
	submap_id_ = submap_id;
	origin_ = origin;
	dmCluster = new DynmeansCluster();
	xs.clear();
	ys.clear();
}

FlirtSubmap::FlirtSubmap(FlirtSubmap* map){
	agent_id_ = map->get_agent_id();
	submap_id_ = map->get_submap_id();
	map->get_origin(origin_);

	xs.clear();
	ys.clear();
	map->get_feature_x(xs);
	map->get_feature_y(ys);
	dmCluster = new DynmeansCluster();
}

FlirtSubmap::~FlirtSubmap(){};

void FlirtSubmap::add_feature(double x, double y){
	xs.push_back(x);
	ys.push_back(y);
}

void FlirtSubmap::get_feature_x(vector<double>& px){
	px.clear();
	px = xs;
}

void FlirtSubmap::get_feature_y(vector<double>& py){
	py.clear();
	py = ys;
}

void FlirtSubmap::get_origin(isam::Pose2d& origin){
	origin = origin_;
}

void FlirtSubmap::set_origin(isam::Pose2d& origin){
	origin_ = origin;
}

void FlirtSubmap::cluster_features(unsigned k){
	dmCluster->reset();
	dmCluster->cluster(xs,ys);
	dmCluster->top_k(k);
	vector<Eigen::Vector2d> cluster_centers;
	dmCluster->get_cluster_centers(cluster_centers);
	xs.clear();
	ys.clear();
	for (unsigned i = 0; i < cluster_centers.size(); ++i){
		Eigen::Vector2d vec = cluster_centers[i];
		xs.push_back(vec(0));
		ys.push_back(vec(1));
	}
}

unsigned FlirtSubmap::get_num_features(){
	return xs.size();
}

unsigned FlirtSubmap::get_agent_id(){
	return agent_id_;
}

unsigned FlirtSubmap::get_submap_id(){
	return submap_id_;
}