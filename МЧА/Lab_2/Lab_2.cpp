#include <iostream>
#include "Matrix.h"

int main()
{
    Matrix matr(12);

    if (matr.rang() != matr.rang_2()) {
        std::cout << "Error 1";
        return 0;
    }
    if (matr.rang() < 5) {
        std::cout << "Error 2";
        return 0;
    }
    if (matr.diagonal()) {
        std::cout << "Error 3";
        return 0;
    }

    std::cout << matr.rang() << ", " << matr.rang_2();
    // 1 method
    std::cout << "    *********************** 1 Method ************************" << std::endl << std::endl;
    std::cout << "Original matrix:" << std::endl;
        
    matr.print_A_2();
    int iterations = 0;
    std::vector<double> vect = matr.seidelMethod(iterations);

    std::cout << iterations << "\n";
    int t = 0;
    for (auto i : vect) {
        std::cout << ++t << ". " << i << "\n";
    }

    std::cout << "\n\n    *********************** 2 Method ************************" << std::endl << std::endl;
    std::cout << "Original matrix:" << std::endl;
    matr.compute_A();
    matr.compute_A_2();
    matr.print_A_2();

    
    iterations = 0;
    vect = matr.simpleIterations(iterations);

    std::cout << iterations << "\n";
    t = 0;
    for (auto i : vect) {
        std::cout << ++t << ". " << i << "\n";
    }
}
