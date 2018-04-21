#include <stdio.h>
#include <thrust/device_vector.h>
#include <thrust/execution_policy.h>
#include <thrust/random/linear_congruential_engine.h>
#include <thrust/random/uniform_int_distribution.h>
#include <thrust/for_each.h>
#include <thrust/generate.h>
#include <thrust/copy.h>

#include <thrust/complex.h>
#include <cufft.h>
#include<vector>
#include <algorithm>

using std::vector;


/*void finalize(vector <int> num)
{
    for (int i = 0; i < num.size(); i ++)
    {

        num[i + 1] += num[i] / 10;
        if (num[i] >= 0) num[i] %= 10;
        else {num[i] = 10 + num[i]%10; num[i+1] --;}
    }
}*/

__global__ void finalize(int* num, int size)
{
    for (int i = 0; i < size; i ++)
    {

        num[i + 1] += num[i] / 10;
        if (num[i] >= 0) num[i] %= 10;
        else {num[i] = 10 + num[i]%10; num[i+1] --;}
    }
}

vector<int> naive_mul(const vector<int>& x, const vector<int>& y)
{
    int len = 0;
    if (x.size() > y.size()) len = x.size();
    else len = y.size();
    vector<int> res(2 * len);

    for (int i = 0; i < x.size(); i ++)
        for (int j = 0; j < y.size(); j ++) res[i + j] += x[i] * y[j];

    return res;
}

vector<int> karatsuba_mul(const vector<int>& _x, const vector<int>& _y)
{
//printf ("karr\n");
    vector <int> x(_x), y(_y);
    int len = 0;
    if (x.size() > y.size()) {len = x.size(); y.reserve(len); y.insert(y.end(), x.size() - y.size(), 0);}
    else {len  = y.size(); x.reserve(len); x.insert(x.end(), y.size() - x.size(), 0);}

    x.reserve (len);
    

    vector <int> res(2 * len);

    if (len <= 50) {
        return naive_mul(x, y);
    }

    int k = len / 2, l = len/2 + len%2;
    vector<int> Xr {x.begin(), x.begin() + k};
    vector<int> Xl {x.begin() + k, x.end()};
    vector<int> Yr {y.begin(), y.begin() + k};
    vector<int> Yl {y.begin() + k, y.end()};

    vector<int> P1 = karatsuba_mul(Xl, Yl);
    vector<int> P2 = karatsuba_mul(Xr, Yr);


    vector<int> Xlr(Xl);
    vector<int> Ylr(Yl);

    for (int i = 0; i < k; i ++)
    {
        Xlr[i] += Xr[i];
        Ylr[i] += Yr[i];
    }


    vector<int> P3 = karatsuba_mul(Xlr, Ylr);

    for (int i = 0;   i < P1.size(); i ++) P3 [i] -= P1[i];
    for (int i = 0;   i < P2.size(); i ++) P3 [i] -= P2[i];

    for (int i = 0;   i < P2.size()      ; i ++) res[i]  = P2[i];
    for (int i = 2*k; i < P1.size() + 2*k; i ++) res[i]  = P1[i - 2*k];
    for (int i = k;   i < P3.size() + k  ; i ++) res[i] += P3[i - k];


    return res;
}

struct PrintIntVector
{
  __device__
  void operator () (int val)
  {     
	printf ("%d ", val);
    //printf ("\n");
  }
};


struct PrintComplexVector
{
  __device__
  void operator () (thrust::complex<float> val)
  {     
	printf ("%.1f + %.1fi ", val.real(), val.imag());
    //printf ("\n");
  }
};

struct PrintFloatVector
{
  __device__
  void operator () (float val)
  {     
	printf ("%.1f ", val);
    //printf ("\n");
  }
};

struct GenRand
{
    __device__
    int operator () (int idx)
    {
        thrust::minstd_rand rng;
        thrust::uniform_int_distribution<int> dist(0, 9);
        rng.discard(idx+100);
       // printf ("=%d", dist(rng));
        return (dist(rng) + idx)%10;
    }
};

struct Round
{
    __device__
    int operator () (float val)
    {
        return round(val);
    }
};

const int LEN_  = 2, MAX_ = 50000, STEP_ = 10;


int main()
{
    FILE * f = fopen ("time.txt", "w");
    //FILE * f2 = fopen ("kar.txt", "w");

    thrust::device_vector<int>                    a_int(LEN_, 1), b_int(LEN_, 1);
    thrust::device_vector<float> a_c  (2*LEN_), b_c  (2*LEN_);
    thrust::device_vector<thrust::complex<float>> c_c  (LEN_);
    thrust::device_vector<float> c_f  (LEN_);
    thrust::device_vector<int>                    c_int(LEN_);
    
    vector <int> a_k (LEN_/2), b_k (LEN_/2);

    a_k.reserve(MAX_/2); b_k.reserve(MAX_/2); a_int.reserve(MAX_); b_int.reserve(MAX_); a_c.reserve(MAX_*2); b_c.reserve(MAX_*2);
    c_c.reserve(MAX_); c_int.reserve(MAX_); c_f.reserve(MAX_);
cufftHandle plan, plan2;
    for (int i = LEN_; i < MAX_; i += STEP_)
    {
        //thrust::transform(thrust::make_counting_iterator(0), thrust::make_counting_iterator(i/2), a_int.begin(), GenRand());
        //thrust::transform(thrust::make_counting_iterator(0), thrust::make_counting_iterator(i/2), b_int.begin(), GenRand());
        
        thrust::copy (a_int.begin(), a_int.end(), a_c.begin());
        thrust::copy (b_int.begin(), b_int.end(), b_c.begin());

        int time1 = clock();
        cufftPlan1d(&plan,  i, CUFFT_R2C, 1);
        cufftPlan1d(&plan2, i, CUFFT_C2R, 1);
	    cufftExecR2C(plan, (cufftReal*) a_c.data().get(), (cufftComplex*) a_c.data().get());	
	    cufftExecR2C(plan, (cufftReal*) b_c.data().get(), (cufftComplex*) b_c.data().get());    
        thrust::transform(thrust::device, (thrust::complex<float>*) a_c.data().get(), (thrust::complex<float>*) a_c.data().get() + i, 
                                         (thrust::complex<float>*) b_c.data().get(), c_c.begin(),  thrust::multiplies<thrust::complex<float>>());
        cufftExecC2R(plan2, (cufftComplex *)c_c.data().get(), (cufftReal *)c_f.data().get());

        thrust::transform (c_f.begin(), c_f.end(), c_int.begin(), [i] __device__ (float val) {return round(val)/i;});
        finalize<<<1,1>>>(c_int.data().get(), c_int.size());
        cudaDeviceSynchronize();
        time1 = clock() - time1;
        cufftDestroy(plan); cufftDestroy(plan2);
        generate (a_k.begin(), a_k.end(), rand);
        generate (b_k.begin(), b_k.end(), rand);
        int time2 = clock();
        c_int == karatsuba_mul (a_k, b_k);
        finalize<<<1,1>>>(c_int.data().get(), c_int.size());
        time2 = clock() - time2;


        a_k  .insert(a_k  .end(), STEP_/2, 0);
        b_k  .insert(b_k  .end(), STEP_/2, 0);
        a_c  .insert(a_c  .end(), STEP_*2, 0.0);
        b_c  .insert(b_c  .end(), STEP_*2, 0.0);
        a_int.insert(a_int.end(), STEP_,   1);
        b_int.insert(b_int.end(), STEP_,   1);
        c_c  .insert(c_c  .end(), STEP_,   (0.0, 0.0));
        c_f  .insert(c_f  .end(), STEP_,   0.0);
        c_int.insert(c_int.end(), STEP_,   0);
        
        fprintf (f, "%d %d %d\n", i, time1, time2);
        if (i%1000 == 2) printf ("sizea = %d sizeb = %d %d\n", a_c.size(), b_c.size(), i);
    }
    


    /*for (int i = 12; i < 13; i +=2)
    {
       // printf ("started %d it\n", i);        
        thrust::transform(thrust::make_counting_iterator(0), thrust::make_counting_iterator(i/2), a.begin(), GenRand());
        thrust::transform(thrust::make_counting_iterator(0), thrust::make_counting_iterator(i/2), b.begin(), GenRand());

        thrust::copy (a.begin(), a.end(), cf.begin());
        thrust::copy (a.begin(), a.end(), cf.begin());
       // printf ("arrays prepared\n");
        
        ////////////////////////
	    cudaEvent_t start, stop;
	    float time;
	    cudaEventCreate(&start);
	    cudaEventRecord(start, 0);
	    cudaEventCreate(&stop);
        ////////////////////////
	    int time1 = clock();
        cufftPlan1d(&plan, i, CUFFT_R2C, 1);
	    cufftExecR2C(plan, (cufftReal *)af.data().get(), (cufftComplex *)af.data().get());	
	    cufftExecR2C(plan, (cufftReal *)bf.data().get(), (cufftComplex *)bf.data().get());
        thrust::transform(af.begin(), af.end(), bf.begin(), cf.begin(),  thrust::multiplies<thrust::complex<float>>());
        cufftExecC2R(plan, (cufftComplex *)cf.data().get(), (cufftReal *)cf.data().get());
        cudaDeviceSynchronize();
        time1 = clock() - time1;
        //////////////////////////////////////////////
	    cudaEventRecord(stop, 0);
	    cudaEventSynchronize(stop);
	    cudaEventElapsedTime(&time, start, stop);
	 //   printf ("Time for the kernel: %f ms\n", time);
	    //////////////////////////////////////////////
srand(13);

        int time2 = clock();
   // printf("haha\n");
        vector <int> ak (i);
        vector <int> bk (i);
        generate (ak.begin(), ak.end(), rand);
        generate (bk.begin(), bk.end(), rand);
        c = karatsuba_mul (ak, bk);
        time2 = clock() - time2;

        fprintf (f, "%d %d %d\n", i, time1, time*1000);
        //printf ("%d %f %f\n", i, time*1000.0, ((float)time2)/CLOCKS_PER_SEC);
        a.push_back(0);
        b.push_back(0);
        af.push_back(0.0);
        bf.push_back(0.0);
        a.push_back(0);
        b.push_back(0);
        af.push_back(0.0);
        bf.push_back(0.0);
    }*/
     
    //cudaDeviceSynchronize();
    //thrust::for_each (arr.begin(), arr.begin() + 5, PrintVector()); 
    
    return 0;
}

