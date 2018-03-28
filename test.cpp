#include "karatsuba.h"

int main ()
{
    vector<int> n1 = {1, 2, 3, 4, 5, 6, 7, 8, 1, 5, 6, 6, 5};
    vector<int> n2 = {4, 2, 3, 4, 5, 6, 5, 6, 5, 3, 3, 4, 5};

    vector<int> res = naive_mul (n1, n2);

    finalize (res);

    for (int i = 0; i < res.size(); i ++) printf ("%d ", res [i]); printf("\n");

    res = karatsuba_mul (n1, n2);

    finalize (res);

    for (int i = 0; i < res.size(); i ++) printf ("%d ", res [i]);

    return 0;
}
