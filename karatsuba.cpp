#include "karatsuba.h"

void finalize(vector <int> num)
{
    for (int i = 0; i < num.size(); i ++)
    {

        num[i + 1] += num[i] / 10;
        if (num[i] >= 0) num[i] %= 10;
        else {num[i] = 10 + num[i]%10; num[i+1] --;}
    }
}

int size(vector <int> num)
{
        int size = 0; 
        for (size = num.size() - 1; num[size] == 0 && size > 0; size --);
        return size + 1;
}

void print_vector (vector <int> vec) 
{
    for (int i = 0; i < vec.size(); i ++) printf ("%d ", vec [i]); 
    printf("\n");
}

void print_ivector (vector <int> vec) 
{    
    for (int i = vec.size()-1; i >= 0; i --) printf ("%d ", vec [i]); 
    printf("\n");
}

vector<int> naive_mul(const vector<int>& x, const vector<int>& y)
{
    int len = 0;
    if (x.size() > y.size()) len = x.size();
    else len = y.size();
    vector<int> res(x.size() + y.size());

    for (int i = 0; i < x.size(); i ++)
        for (int j = 0; j < y.size(); j ++) res[i + j] += x[i] * y[j];

    return res;
}

vector<int> karatsuba_mul(const vector<int>& _x, const vector<int>& _y)
{

    vector <int> x(_x), y(_y);
    int len = 0;

    if (size(x) < 6.6*pow(size(y), 0.585) + 60.7 || size(y) < 6.6*pow(size(x), 0.585) + 60.7) return naive_mul (x,y);


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
