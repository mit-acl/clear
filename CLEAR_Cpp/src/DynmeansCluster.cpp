#include <clear/DynmeansCluster.hpp>
#include <ros/console.h>


DynmeansCluster::DynmeansCluster(){
	dynmean_ = new DynMeans<Vector2d>(lambda_dynm, lambda_dynm/T_Q_dynm, (T_Q_dynm*(K_tau - 1.0)+1.0)/(T_Q_dynm-1.0));
}

DynmeansCluster::~DynmeansCluster(){}


void DynmeansCluster::reset(){
	dynmean_->reset();
	cluster_xs_.clear();
	cluster_ys_.clear();
	cluster_size_.clear();
	cluster_centers_.clear();
	init_ = false;
}

void DynmeansCluster::cluster(vector<double> xs, vector<double> ys)
{
	reset();
	init_ = true;

	// form data array
	vector<Vector2d> data;
	for (unsigned i = 0; i < xs.size(); ++i) {
		double x = xs[i];
		double y = ys[i];
		Vector2d pt(x, y);
		data.push_back(pt);
	}

	vector<int> learned_labels;
	vector<int> unused_labels;
	double final_obj, time_elapsed;
	dynmean_->cluster(data, n_restarts_, learned_labels, cluster_centers_, unused_labels, final_obj, time_elapsed);

	unsigned num_clusters = cluster_centers_.size();
	cluster_xs_.resize(num_clusters);
	cluster_ys_.resize(num_clusters);
	cluster_size_.resize(num_clusters, 0);

	// assign points to different clusters
	for (unsigned idx = 0; idx < learned_labels.size(); ++idx) {
		int cluster_label = learned_labels[idx];
		cluster_size_[cluster_label] += 1;
		cluster_xs_[cluster_label].push_back(xs[idx]);
		cluster_ys_[cluster_label].push_back(ys[idx]);
	}
}


void DynmeansCluster::top_k(unsigned k)
{
	if(!init_){return;}

	vector<vector<double>> xs_out;
	vector<vector<double>> ys_out;
	vector<unsigned> size_out;
	vector<Vector2d> centers_out;

	unsigned num_clusters = cluster_xs_.size();
	k = std::min(k, num_clusters);
	
	// sort clusters in descending order of size
	vector<unsigned> cluster_indices_sorted(cluster_size_.size());
	iota(cluster_indices_sorted.begin(), cluster_indices_sorted.end(), 0);
	vector<unsigned> v = cluster_size_;
	sort(cluster_indices_sorted.begin(), cluster_indices_sorted.end(),
       [&v](unsigned i1, unsigned i2) {return v[i1] > v[i2];});

	for (unsigned i = 0; i < k; ++i){
		unsigned chosen_cluster_index = cluster_indices_sorted[i];
		xs_out.push_back(cluster_xs_[chosen_cluster_index]);
		ys_out.push_back(cluster_ys_[chosen_cluster_index]);
		size_out.push_back(cluster_size_[chosen_cluster_index]);
		centers_out.push_back(cluster_centers_[chosen_cluster_index]);
	}

	cluster_xs_ = xs_out;
	cluster_ys_ = ys_out;
	cluster_size_ = size_out;
	cluster_centers_ = centers_out;
}

void DynmeansCluster::get_cluster_size(vector<unsigned>& cluster_size){
	if(!init_){return;}
	cluster_size = cluster_size_;
}

void DynmeansCluster::get_cluster_xs(vector<vector<double>>& cluster_xs){
	if(!init_){return;}
	cluster_xs = cluster_xs_;
}

void DynmeansCluster::get_cluster_ys(vector<vector<double>>& cluster_ys){
	if(!init_){return;}
	cluster_ys = cluster_ys_;
}

void DynmeansCluster::get_cluster_centers(vector<Vector2d>& cluster_centers){
	if(!init_){return;}
	cluster_centers = cluster_centers_;
}

unsigned DynmeansCluster::get_num_clusters(){
	return cluster_centers_.size();
}