#ifndef CLEAR_UTILS_H
#define CLEAR_UTILS_H

#include <cmath>
#include <cfloat>
#include <vector>
#include <numeric>

#include <Eigen/Dense>
#include <Eigen/Core>

#include <geometry_msgs/PoseStamped.h>
#include <geometry_msgs/Pose.h>
#include <sensor_msgs/LaserScan.h>
#include <sensor_msgs/PointCloud.h>
#include <geometry_msgs/Point32.h>

using Eigen::Matrix3f;
using Eigen::Matrix4f;
using Eigen::Vector2f;
using Eigen::Vector3f;
using Eigen::Vector4f;
using std::vector;
using sensor_msgs::PointCloud;
using geometry_msgs::Point32;

// template <class T>
// int index_max(const std::vector<T>& v) {


inline Vector3f transform_point_to_global_frame(float x, float y, geometry_msgs::Pose pose) {
  // Transform points x, y taken in the local frame of pose into the global frame at the 0,0,0 origin.
  float t = 2*std::atan2(pose.orientation.z, pose.orientation.w);
  float c = std::cos(t);
  float s = std::sin(t);
  Matrix3f H_l_g;
  H_l_g << c, -s, pose.position.x, s, c, pose.position.y, 0.0f, 0.0f, 1.0f;
  Vector3f p_in;
  p_in << x, y, 1.0f;
  Vector3f p_out = H_l_g*p_in;
  return p_out;
}

inline Vector2f transform_point_to_global_frame2(float x, float y, geometry_msgs::Pose pose) {
  Vector3f p = transform_point_to_global_frame(x, y, pose);
  Vector2f p_out;
  p_out << p(0), p(1);
  return p_out;
}

inline Vector3f transform_point_to_local_frame(float x, float y, geometry_msgs::Pose pose) {
  // Transform points x, y taken in the GLOBAL frame at the 0,0,0 origin into the LOCAL frame.
  float t = 2*std::atan2(pose.orientation.z, pose.orientation.w);
  float c = std::cos(t);
  float s = std::sin(t);
  Matrix3f H_l_g;
  H_l_g << c, -s, pose.position.x, s, c, pose.position.y, 0.0f, 0.0f, 1.0f;
  Vector3f p_in;
  p_in << x, y, 1.0f;
  Vector3f p_out = (H_l_g.inverse())*p_in;
  return p_out;
}


#endif