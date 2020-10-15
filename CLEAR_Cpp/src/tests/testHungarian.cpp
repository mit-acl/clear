#include <iostream>
#include "clear/Hungarian.h"


int main(void)
{
    // please use "-std=c++11" for this initialization of vector.
	// vector< vector<double> > costMatrix = { { 10, 19, 8, 15, 21 }, 
	// 									  { 10, 18, 7, 17, 0 }, 
	// 									  { 13, 16, 9, 14, -5 }, 
	// 									  { 12, 19, 8, 18, 5 } };

    
    vector< vector<double> > costMatrix = {{ 0, 1, 1 }, 
										  { 10, 0, 7 }, 
										  { 13, 16, 0}, 
										  { 12, 19, 8}};

	HungarianAlgorithm HungAlgo;
	vector<int> assignment;

	double cost = HungAlgo.Solve(costMatrix, assignment);

	for (unsigned int x = 0; x < costMatrix.size(); x++)
		std::cout << x << "," << assignment[x] << "\t";

	std::cout << "\ncost: " << cost << std::endl;

	return 0;
}
