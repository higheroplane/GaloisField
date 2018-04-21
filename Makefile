CC = g++ 
CU = nvcc
CUFLAGS = -Wno-deprecated-gpu-targets -std=c++11 -lcufft --expt-extended-lambda

all:
	$(CU) $(CUFLAGS) $(CFLAGS) -c main.cu
	$(CU) $(CUFLAGS) $(CFLAGS) -o  main main.o  -lcudadevrt
	./main
	make clean
	gnuplot plot.p



clean:
	rm -rf *.o

run:
	sshpass -p '12345' scp 192.168.1.100 -p 13250 < password
