#include <stdio.h>
#include <vector>

using namespace std;

void print_vector (vector <int> vec) {for (int i = 0; i < vec.size(); i ++) printf ("%d ", vec [i]); printf("\n");}

//vector<int> add (const vector<int>& x, const vector<int>& y)

//vector<int> sub(const vector<int>& x, const vector<int>& y)


void finalize(vector<int>& res)
{
    for (int i = 0; i < res.size(); i ++)
    {

        res[i + 1] += res[i] / 10;
        if (res[i] >= 0) res[i] %= 10;
        else {res[i] = 10 + res[i]%10; res[i+1] --;}
    }
}

vector<int> naive_mul(const vector<int>& x, const vector<int>& y)
{
    auto len = x.size();
    vector<int> res(2 * len);

    for (int i = 0; i < len; i ++)
        for (int j = 0; j < len; j ++) res[i + j] += x[i] * y[j];

    return res;
}

vector<int> karatsuba_mul(const vector<int>& x, const vector<int>& y)
{

    printf ("started multiplying ");
    print_vector (x);
    printf ("to ");
    print_vector (y);
    printf ("\n");

    int len = 0;
    if (x.size() > y.size()) len = x.size();
    else len  = y.size();


    vector<int> res(2 * len);

    if (len <= 8) {
        return naive_mul(x, y);
    }

    int k = len / 2, l = len/2 + len%2;

    vector<int> Xr {x.begin(), x.begin() + k};
    vector<int> Xl {x.begin() + k, x.end()};
    vector<int> Yr {y.begin(), y.begin() + k};
    vector<int> Yl {y.begin() + k, y.end()};

   // printf ("vectors division done\n");

    vector<int> P1 = karatsuba_mul(Xl, Yl);
    vector<int> P2 = karatsuba_mul(Xr, Yr);

    /*printf ("ended multiplying ");
    print_vector (x);
    printf ("to ");
    print_vector (y);
    printf ("\n");   */

    vector<int> Xlr(Xl);
    vector<int> Ylr(Yl);

    for (int i = 0; i < k; i ++)
    {
        Xlr[i] += Xr[i];
        Ylr[i] += Yr[i];
    }
    printf("\n");printf("\n");
    print_vector (Xlr);
    printf("\n");
    print_vector (Ylr);
    printf("\n");printf("\n");

    vector<int> P3 = karatsuba_mul(Xlr, Ylr);

    for (int i = 0;   i < P1.size(); i ++) P3 [i] -= P1[i];
    for (int i = 0;   i < P2.size(); i ++) P3 [i] -= P2[i];

    for (int i = 0;   i < P2.size()      ; i ++) res[i]  = P2[i];
    for (int i = 2*k; i < P1.size() + 2*k; i ++) res[i]  = P1[i - 2*k];
    for (int i = k;   i < P3.size() + k  ; i ++) res[i] += P3[i - k];


    return res;
}
