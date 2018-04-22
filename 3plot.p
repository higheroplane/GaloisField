set term png
set output "logn.png"

#set dgrid3d 1,1
#set pm3d map
#set yrange [0:500]
f(x) = a*x**(0.585) + b
fit f(x) "tm.txt" using 1:2 via a,b
ti = sprintf ("%.1f x^{log_23 - 1} + %.1f", a, b)
set title ti
plot "tm.txt" u 1:2  with lines , f(x) with lines
