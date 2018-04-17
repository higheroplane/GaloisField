set terminal png
set grid

plot "k.txt" using 1:2 with lines, "k.txt" using 1:3 with lines
