set term png

#set dgrid3d 1,1
#set pm3d map
#set yrange [0:500]
plot "tm.txt" u 1:2:3 lc variable, 12*sqrt(x) - 30
