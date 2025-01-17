#include "Matrix.h"
#include <vector>

Matrix::Matrix(const int V) : V(V) {
    std::cout << std::fixed << std::setprecision(4);
    compute_A();
    compute_A_2();
}

void Matrix::compute_A() {
    for (int i = 0; i < 5; i++) {
        for (int j = 0; j < 5; j++) {
            A[i][j] = V * C[i][j] + D[i][j];
        }
    }
}

void Matrix::compute_A_2() {
    for (int i = 0; i < 5; i++) {
        for (int j = 0; j < 5; j++) {
            A_2[i][j] = A[i][j];
        }
    }

    A_2[0][5] = 12.0 / 10;
    A_2[1][5] = 22.0 / 10;
    A_2[2][5] = 40.0 / 10;
    A_2[3][5] = 0;
    A_2[4][5] = -12.0 / 10;

}

void Matrix::print_A() {
    for (int i = 0; i < 5; i++) {
        for (int j = 0; j < 5; j++) {
            std::cout << std::setw(10) << A[i][j];
        }
        std::cout << std::setw(5) << '|' << std::setw(5) << b[i] << std::endl;
    }
}

void Matrix::print_A_2() {
    for (int i = 0; i < 5; i++) {
        for (int j = 0; j < 5; j++) {
            std::cout << std::setw(10) << A_2[i][j];
        }
        std::cout << std::setw(5) << '|' << std::setw(5) << A_2[i][5] << std::endl;
    }
}



std::vector<double> Matrix::simpleIterations(int& iterations) {

    // Размер матрицы
    int size = 5;


    // Неизвестные на предыдущей итерации
    std::vector <double> prev_X(size, 0.0);

    // Пока не будет достигнута точность
    bool stop = false;
    while (!stop)
    {
        ++iterations;
        // Неизвестные на текущей итерации   
        std::vector <double> current_X(size);

        for (int i = 0; i < size; i++)
        {
            // x_i = b_i
            current_X[i] = A_2[i][size];

            // Вычитаем сумму по всем отличным от i-ой неизвестным
            for (int j = 0; j < size; j++)
            {
                // С прошлой итерации
                if (j != i)
                    current_X[i] -= A_2[i][j] * prev_X[j];
            }

            // x_i /= b_i
            current_X[i] /= A_2[i][i];
        }

        // Максимальная погрешность
        long double max_error = 0.0;
        for (int i = 0; i < size; i++) {
            double new_max_error = abs(current_X[i] - prev_X[i]);
            max_error = new_max_error > max_error ? new_max_error : max_error;
        }

        // Дотигнута ли точность
        if (max_error < 0.0001)
            stop = true;


        // Переход к следующей итерации
        prev_X = current_X;
    }


    return prev_X;

}

std::vector<double> Matrix::seidelMethod(int& iterations) {

    // Размер матрицы
    int size = 5;


    // Неизвестные на предыдущей итерации
    std::vector <double> prev_X(size, 0.0);

    // Пока не будет достигнута точность
    bool stop = false;
    while (!stop)
    {
        ++iterations;
        // Неизвестные на текущей итерации   
        std::vector <double> current_X(size);

        for (int i = 0; i < size; i++)
        {
            // x_i = b_i
            current_X[i] = A_2[i][size];

            // Вычитаем сумму по всем отличным от i-ой неизвестным
            for (int j = 0; j < size; j++)
            {
                // С этой итерации
                if (j < i)
                    current_X[i] -= A_2[i][j] * current_X[j];

                // С прошой итерации
                if (j > i)
                    current_X[i] -= A_2[i][j] * prev_X[j];

            }

            // x_i /= b_i
            current_X[i] /= A_2[i][i];
        }

        // Максимальная погрешность
        long double max_error = 0.0;
        for (int i = 0; i < size; i++) {
            double new_max_error = abs(current_X[i] - prev_X[i]);
            max_error = new_max_error > max_error ? new_max_error : max_error;
        }

        // Дотигнута ли точность
        if (max_error < 0.0001)
            stop = true;


        // Переход к следующей итерации
        prev_X = current_X;
    }


    return prev_X;


}

int Matrix::rang()
{
    int rang = 5;
    //std::cout << "\nf_rang = " << rang << std::endl;
    double sum = 0;
    for (int i = 0; i < 5; i++)
    {
        for (int j = 0; j < 5; j++)
            sum += A[i][j];
        //std::cout << "sum  = " << sum << std::endl;
        if (sum == 0)
            rang = rang - 1;
        //std::cout << "rang " << i << "  = " << rang << std::endl;
        sum = 0;

    }

    //std::cout << "end rang = " << rang << std::endl;
    return rang;
}
int Matrix::rang_2()
{
    int rang = 6;
    //std::cout << "\nf_rang = " << rang << std::endl;
    double sum = 0;
    for (int i = 0; i < 6; i++)
    {
        for (int j = 0; j < 6; j++)
            sum += A_2[i][j];
        //std::cout << "sum  = " << sum << std::endl;
        if (sum == 0)
            rang = rang - 1;
        //std::cout << "rang " << i << "  = " << rang << std::endl;
        sum = 0;

    }

    //std::cout << "end rang = " << rang << std::endl;
    return rang;
}

bool Matrix::diagonal()
{
    int i, j, k = 1;
    double sum;
    for (i = 0; i < 5; i++)
    {
        sum = 0;
        for (j = 0; j < 5; j++)
            sum += A[i][j];
        sum -= A[i][i];
        if (sum < A[i][i])
        {
            return 0;
           
        }
        
    }
    return (k == 1);
}