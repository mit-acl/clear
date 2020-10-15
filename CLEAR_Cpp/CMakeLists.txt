cmake_minimum_required(VERSION 3.1)
project(clear)

set(CMAKE_CXX_STANDARD 11)

# Find Eigen3
message(STATUS "CMAKE_SOURCE_DIR: ${CMAKE_SOURCE_DIR}")
find_package(Eigen3 REQUIRED)
if(Eigen3_FOUND)
message(STATUS "Found Eigen3, version: ${EIGEN3_VERSION_STRING}")
message(STATUS "Eigen3 include directory: ${EIGEN3_INCLUDE_DIR}\n")
else()
message(FATAL_ERROR "Could not find Eigen!")
endif()

include_directories(${PROJECT_SOURCE_DIR}/include
  ${EIGEN3_INCLUDE_DIR})

add_executable(test_hungarian
 src/tests/testHungarian.cpp
 src/Hungarian.cpp
)

add_executable(test_mygraph
 src/tests/testMyGraph.cpp
 src/MyGraph.cpp
)

add_executable(test_block_svd
 src/tests/testBlockSVD.cpp
 src/MyGraph.cpp
)

add_library(clear SHARED
        src/MultiwayMatcher.cpp
        src/Hungarian.cpp
        src/MyGraph.cpp)

INSTALL(TARGETS clear
        ARCHIVE DESTINATION lib
        LIBRARY DESTINATION lib
        )

INSTALL(DIRECTORY include/clear
        DESTINATION include
        )


add_executable(clear_tests
        src/tests/clearUnitTests.cpp)
target_include_directories(clear_tests PRIVATE external)
target_link_libraries(clear_tests clear)








