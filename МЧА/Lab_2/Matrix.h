#pragma once
#include <iostream>
#include <iomanip>
#include <vector>

class Matrix {
private:
	int V;			 // variant

	double A[5][5];
	double A_2[5][6];
	double C[5][5]
	{
		{1.0 / 100, 0, -2.0 / 100, 0, 0},
		{1.0 / 100, 1.0 / 100, -2.0 / 100, 0, 0},
		{0, 1.0 / 100, 1.0 / 100, 0, -2.0 / 100},
		{0, 0, 1.0 / 100, 1.0 / 100, 0},
		{0, 0, 0, 1.0 / 100, 1.0 / 100}
	};

	double D[5][5]
	{
		{133.0 / 100, 21.0 / 100, 17.0 / 100, 12.0 / 100, -13.0 / 100},
		{-13.0 / 100, -133.0 / 100, 11.0 / 100, 17.0 / 100, 12.0 / 100},
		{12.0 / 100, -13.0 / 100, -133.0 / 100, 11.0 / 100, 17.0 / 100},
		{17.0 / 100, 12.0 / 100, -13.0 / 100, -133.0 / 100, 11.0 / 100},
		{11.0 / 100, 67.0 / 100, 12.0 / 100, -13.0 / 100, -133.0 / 100}
	};

	double b[5]{ 12.0 / 10, 22.0 / 10, 40.0 / 10, 0, -12.0 / 10 };
	double roots[5]{ 0, 0, 0, 0, 0 };

public:
	Matrix(const int V);

	void compute_A();
	void compute_A_2();
	void print_A();
	void print_A_2();
	std::vector<double> simpleIterations(int& iterations);
	std::vector<double> seidelMethod(int& iterations);
	int rang();
	int rang_2();
	bool diagonal();
};