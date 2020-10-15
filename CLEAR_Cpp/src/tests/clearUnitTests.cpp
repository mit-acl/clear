//
// Created by stewart on 2/10/20.
//

#define CATCH_CONFIG_MAIN

#include "catch.hpp"
#include "clear/MultiwayMatcher.hpp"
#include <Eigen/Core>

TEST_CASE("Identity Case", "[identity]") {
  for (auto size = 1; size <= 10; ++size) {
    Eigen::MatrixXf input = Eigen::MatrixXf::Constant(size, size, 0);
    std::vector<uint32_t> numSmp = std::vector<uint32_t>(size, 1);
    MultiwayMatcher matcher;
    matcher.initialize(input, numSmp);
    matcher.CLEAR();
    REQUIRE(matcher.get_universe_size() == size);

    Eigen::MatrixXf outputX = matcher.get_X();
    REQUIRE(outputX.isApprox(Eigen::MatrixXf::Identity(size, size)));
    // TODO check other clear values
  }
}

TEST_CASE("Complete Graph", "[complete]") {
  for (auto size = 1; size <= 10; ++size) {
    Eigen::MatrixXf input = Eigen::MatrixXf::Constant(size, size, 1) - Eigen::MatrixXf::Identity(size, size);
    std::vector<uint32_t> numSmp = std::vector<uint32_t>(size, 1);
    MultiwayMatcher matcher;
    matcher.initialize(input, numSmp);
    matcher.CLEAR();
    REQUIRE(matcher.get_universe_size() == 1);

    Eigen::MatrixXf outputX = matcher.get_X();
    REQUIRE(outputX.isApprox(Eigen::MatrixXf::Constant(size, size, 1)));
    // TODO check other clear values
  }
}