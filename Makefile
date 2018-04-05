all:
	g++ -c -std=c++11 test.cpp
	g++ -o test test.o
	./test
	gnuplot kplot.p >filek.png
