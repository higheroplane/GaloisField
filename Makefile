CC = g++
CFLAGS = -c -std=c++11 -Wall

all: test
	./test
	make clean

test: test.o karatsuba.o bigint.o
	$(CC) -o test test.o karatsuba.o bigint.o

test.o: test.cpp
	$(CC) $(CFLAGS)  test.cpp

bigint.o: bigint.cpp
	$(CC) $(CFLAGS)  bigint.cpp

karatsuba.o: karatsuba.cpp
	$(CC) $(CFLAGS)  karatsuba.cpp


clean:
	rm -rf *o 
