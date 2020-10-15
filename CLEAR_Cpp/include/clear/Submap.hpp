#ifndef SUBMAP_H
#define SUBMAP_H

#include <vector>
#include <Eigen/Dense>
#include <Eigen/Core>
#include <geometry_msgs/Pose.h>

using std::vector;
using Eigen::Vector3f;

class Submap{
public:
	Submap(unsigned agent_id, unsigned submap_id);
	// Copy constructor
	Submap(Submap* map);
	~Submap();

	void add_landmark(Vector3f p);
	void get_landmark_count(vector<unsigned>& count);
	void cull_landmark(unsigned threshold);
	unsigned get_num_landmarks();
	vector<Vector3f> get_landmarks();
	unsigned get_agent_id();
	unsigned get_submap_id();
private:
	unsigned agent_id_;
	unsigned submap_id_;
	vector<Vector3f> landmarks_; // detected landmarks in this submap
	vector<unsigned> landmark_count_; // number of times each landmark is observed
	double NN_tol = 3.5; // tolerance for detecting duplicate landmarks in Nearest Neighbor (NN)
};

#endif