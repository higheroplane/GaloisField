set terminal png
set grid

set xlabel "size"
set ylabel "time (ms)"
#set xrange [0:1000]

#f(x) = a*x**2 + b
#g(x) = c**1.585 + d

#fit f(x) "time1.txt" using 1:2 via a, b
#fit g(x) "time1.txt" using 1:3 via c, d

#ti1 = sprintf ("%f x^2 + %f", a, b)
#ti2 = sprintf ("%f x^(log23) + %f", c, d)

plot "time361.txt" using 1:2 with lines, "time361.txt" using 1:3 with lines, "time0.txt" using 1:3 with lines, "time722.txt" using 1:3 with lines
