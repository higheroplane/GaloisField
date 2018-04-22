#include <stdio.h>
#include <cmath>

const int _ADD = 1, _SUB = 2, _MUL = 3, _DIV = 4;

class GF
{
    private:
    int ch;

    public:
    GF (int _ch): ch (_ch) {}

    int add (int x1, int x2);
    int sub (int x1, int x2);
    int mul (int x1, int x2);
    int div (int x1, int x2); 
    void PrintTable (int type); 
};



void EuclideAlg (int a, int b, int * x, int * y, int * d);


int main ()
{
    int a = 158, b = 0, x = 0, y = 0, d = 0;

    EuclideAlg (a, b, &x, &y, &d);    

    printf ("eucle returns d = %d, x = %d, y = %d\n", d, x, y);
    

    GF test (11);
    //test.PrintTable (_ADD);
    //test.PrintTable (_SUB);
   // test.PrintTable (_MUL);
    test.PrintTable (_DIV);

    return 0;
}

int GF::add (int x1, int x2)
{
    return (x1 + x2) % ch;
}

int GF::sub (int x1, int x2)
{
    if (x1 >= x2) return (x1 - x2) % ch;
    else return ch + (x1 - x2) % ch;
}

int GF::mul (int x1, int x2)
{
    return (x1 * x2) % ch;
}

int GF::div (int x1, int x2)
{
    int x = 0, y = 0, d = 0;
    
    EuclideAlg (ch, x2, &x, &y, &d);

    if (y*x1 >= 0) return (y * x1) % ch;
    else return ch + (y * x1) % ch;

    //return (y * x1);
}

void GF::PrintTable (int type)
{
      if (type == 1) printf ("ADD");
      if (type == 2) printf ("SUB");
      if (type == 3) printf ("MUL");
      if (type == 4) printf ("DIV");

      for (int i = 0; i < ch; i ++) printf ("///");
      printf ("\n   ");
      for (int i = 0; i < ch; i ++) printf ("%d_|", i);
        printf ("\n");

      for (int i = 0; i < ch; i++)
      {
            printf ("%d_|", i);            
            for (int j = 0; j < ch; j++)
            {
                if (type == 1) printf ("%2d |", add (i, j));
                if (type == 2) printf ("%2d |", sub (i, j));
                if (type == 3) printf ("%2d |", mul (i, j));
                if (type == 4) printf ("%2d |", div (i, j));
            } 
            printf ("\n"); 
      }
}

void EuclideAlg (int a, int b, int * x, int * y, int * d)
{
    
    if (b == 0)

    {

    *d = a; *x = 1; *y = 0;

        return;

    }

    EuclideAlg(b, a % b, x, y, d);

    int s = *y;

    *y = *x - (a / b) * (*y);

    *x = s;

    return; 
}
