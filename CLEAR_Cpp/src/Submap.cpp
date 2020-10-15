#include <clear/Submap.hpp>
#include <ros/console.h>

using std::vector;
using Eigen::Vector3f;

Submap::Submap(unsigned agent_id, unsigned submap_id){
	agent_id_ = agent_id;
	submap_id_ = submap_id;
	landmarks_.clear();
	landmark_count_.clear();
}

Submap::Submap(Submap* map){
	// TODO
}

Submap::~Submap(){};

void Submap::add_landmark(Vector3f p)
{
	float min_distance = NN_tol + 1;
	int    best_i = -1;
	
	// find closest landmarks
	for (unsigned i = 0; i < landmarks_.size(); ++i){
		Vector3f l = landmarks_[i];
		float distance = (l-p).norm();
		if (distance < min_distance){
			min_distance = distance;
			best_i = i;
		}
	}

	if (best_i >=0 && min_distance < NN_tol){
		// ROS_INFO_STREAM("Merged landmark. min_distance: " << min_distance);
		float current_count = landmark_count_[best_i];
		float new_count = current_count + 1;
		landmark_count_[best_i] = new_count;
		landmarks_[best_i] = (landmarks_[best_i] * current_count + p) / new_count;
	}
	else{
		// ROS_INFO_STREAM("Created new landmark. min_distance: " << min_distance);
		// create new landmark
		// ROS_INFO_STREAM("Created new landmark.");
		landmarks_.push_back(p);
		landmark_count_.push_back(1);
	}
}

void Submap::get_landmark_count(vector<unsigned>& count){}

vector<Vector3f> Submap::get_landmarks(){
	return landmarks_;
}

void Submap::cull_landmark(unsigned threshold){}

unsigned Submap::get_num_landmarks(){
	return landmarks_.size();
}

unsigned Submap::get_agent_id(){
	return agent_id_;
}

unsigned Submap::get_submap_id(){
	return submap_id_;
}