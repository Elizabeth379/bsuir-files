/* Информация о сотрудниках предприятия содержит: Ф.И.О., номер отдела, должность, дату начала работы.
Вывести списки сотрудников по отделам в порядке убывания стажа. */

#include <iostream>
#include <fstream>
#include <string>
using namespace std;

struct Prisoners_of_capitalism {
	string name;
	string number;
	string post;
	string year;
};

void ShellSort(int, Prisoners_of_capitalism*, fstream&);
Prisoners_of_capitalism* newarr(Prisoners_of_capitalism*, short&);
void Choice(Prisoners_of_capitalism*);
void Display1(int, Prisoners_of_capitalism*);
void redaction();

int main() {
	system("color 0E");
	setlocale(0, "");

	short size = 3, i = 0, counter = 0;
	Prisoners_of_capitalism* arr = new Prisoners_of_capitalism[size];
	fstream file;

	file.open("mySlaves.txt", fstream::in | fstream::out | fstream::app);
	if (!file.is_open()) cout << "Ошибка открытия файла\n";
	
	string buf;

	redaction();

	while (!file.eof()) {
		if (counter == 4) {
			counter = 0;
			++i;
			continue;
		}
		if (i == size) break;

		buf = "";
		file >> buf;
		if (buf == "") continue;

		switch (counter) {
		case 0: arr[i].name = buf; break;
		case 1: arr[i].number = buf; break;
		case 2: arr[i].post = buf; break;
		case 3: arr[i].year = buf;
		}
		++counter;
	}
	ShellSort(size, arr, file);

	file.close();
	delete[] arr;
	return 0;
}

Prisoners_of_capitalism* newarr(Prisoners_of_capitalism* arr, short& size) {
	++size;
	Prisoners_of_capitalism* newarr = new Prisoners_of_capitalism[size];

	for (int i = 0; i < size - 1; ++i) {
		newarr[i].name = arr[i].name;
		newarr[i].number = arr[i].number;
		newarr[i].post = arr[i].post;
		newarr[i].year = arr[i].year;
	}
	delete[] arr;
	return newarr;
}

void Choice(Prisoners_of_capitalism* arr) {
	short n; cin >> n;

	cout << arr[n - 1].name; putchar('\t');
	cout << arr[n - 1].number; putchar('\t'); 
	cout << arr[n - 1].post; putchar('\t');
	cout << arr[n - 1].year; putchar('\n');
}

void Display1(int size, Prisoners_of_capitalism* arr) {
	for (int i = 0; i < size; ++i) {
		cout << arr[i].name; putchar('\t');
		cout << arr[i].number; putchar('\t');
		cout << arr[i].post; putchar('\t');
		cout << arr[i].year; putchar('\n');
	}
}

void ShellSort(int n, Prisoners_of_capitalism* mass, fstream& file) {
	int i, j, step;
	string tmp1, tmp2, tmp3; int tmp4;

	for (step = n / 2; step > 0; step /= 2)
		for (i = step; i < n; i++) {
			tmp1 = mass[i].name;
			tmp2 = mass[i].number;
			tmp3 = mass[i].post;
			tmp4 = atoi(mass[i].year.c_str());

			for (j = i; j >= step; j -= step) {
				if (tmp4 < atoi(mass[j - step].year.c_str())) {
					mass[j].name = mass[j - step].name;
					mass[j].number = mass[j - step].number;
					mass[j].post = mass[j - step].post;
					mass[j].year = mass[j - step].year;
				}
				else break;
			}
			mass[j].name = tmp1;
			mass[j].number = tmp2;
			mass[j].post = tmp3;
			mass[j].year = to_string(tmp4);
		}
	Display1(n, mass);
}
void redaction() {
	short position;
	int pointer = 0;

	fstream file;
	string buffer; short answer;
	file.open("mySlaves.txt", fstream::in | fstream::out);

	if (!file.is_open()) {
		cout << "Ошибка открытия файла";
		exit(1);
	}

	short i = 0, j = 0;
	while (!file.eof()) {
		buffer = "";
		getline(file, buffer);
		if (!(i % 4)) cout << '\n';
		++i;
		cout << i << ".\t" << buffer << '\n';
	}
	file.close();
	cout << "\nВыберите действие:\n1 - изменить поле\n2 - удалить поле\n3 - добавить в файл\n4 - ничего не делать\n";
	cin >> answer;

	if (answer == 4) return;

	string empty = "";

	if (answer == 3) goto label;

	cout << "Введите номер поля:\t";
	cin >> position;

	file.open("mySlaves.txt", fstream::in | fstream::out);
	//4
	while (!(file.eof())) {
		--position;
		if (position == 0) break;
		buffer = "";
		getline(file, buffer);
		pointer = pointer + 2 + buffer.length();
	}
	file.close();

	file.open("mySlaves.txt", fstream::in | fstream::out | fstream::binary);

	file.seekp(0);
	file.seekp(pointer);
	getline(file, buffer);

	if (empty.length() < buffer.length()) empty.resize(buffer.length(), ' ');

	file.seekp(0);
	file.seekp(pointer);

	file.write(empty.c_str(), empty.length());

	if (answer == 1) {
		cout << "Введите значение:\t";
		cin >> empty;

		file.seekp(0);
		file.seekp(pointer);
		file.write(empty.c_str(), empty.length());
	}
	file.close();

	file.open("mySlaves.txt", fstream::in | fstream::out);

	file.seekp(0);
	i = 0;

	while (!file.eof()) {
		buffer = "";
		getline(file, buffer);
		if (!(i % 4)) cout << '\n';
		++i;
		cout << i << ".\t" << buffer << '\n';
	}
	file.close();
	return;
label:
	file.open("mySlaves.txt",fstream::in | fstream::out | fstream::app);
	string str="";
	cin >> str;
	file << str;

	file.seekp(0);
	while (!file.eof()) {
		buffer = "";
		getline(file, buffer);
		cout << buffer; putchar('\n');
	}
	file.close();
}