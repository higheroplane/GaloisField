#include "bigint.h"
#include <ctime>
#include <cstdlib>
#include <algorithm>

int my_rand () {return rand()%10;}

int main ()
{
    vector <int> a ({0, 0,1,7,3,4,4,8});
    vector <int> b ({0,0,1});
    
    FILE * f = fopen ("tm.txt", "w");

    BigInt A (vector<int> (3, 4)), B(vector <int> (100, 1)), C (vector<int>(20000,0));
    
    A.print();
    B.print();
    int eq = 0;
    for (int i = 1000; i < 100000; i += 1000)
    {
        eq = 0;        
        for (int j = 1; j < 5000; j += 100)
        {
            A = BigInt (vector <int> (i, 2)),  B = BigInt (vector <int> (j, 2));  
            
            int time1 = 0, time2 = 0;

            time1 = clock();
            C = A*B;
            time1 = clock() - time1;
            
            time2 = clock();
            C = BigInt (naive_mul (A.num, B.num));
            time2 = clock() - time2;
            if (eq == 0 && time2 > time1) {eq = 1; printf ("charade you are\n\n");}
            if (eq == 1) fprintf (f,"%d %d\n", i, j);
            if (eq == 1) {eq = 2;}
            //if (eq == 1) printf ("%d %d\n", i, j);

        }
        

    }
    //(B*A).print();
    //BigInt C(naive_mul(A.num, B.num));
   // C.finalize();
   // C.print();
   // (B*A).print();
    //print_vector ((A*B).num);

    return 0;
}
