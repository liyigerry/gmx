set term 'pngcairo'
set output 'cv.png'
plot 'HILLS' u 2
unset output

set pm3d
splot 'meta_0612_lab133/fes.dat' u 1:2:3

set size square

set table 'height.dat'
plot 'HILLS' u 3