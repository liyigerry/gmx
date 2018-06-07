nohup mpirun -np 4 gmx_mpi mdrun -ntomp 12 -gpu_id 0234 -deffnm md -v -plumed plumed.dat -cpi md.cpt

mpirun -np 4 gmx_mpi mdrun -v -ntomp 18 -gpu_id 0123 -plumed plumed.dat -deffnm md -cpi md.cpt

gmx mdrun -ntmpi 4 -ntomp 12 -gpu_id 0234 -deffnm md -v -cpi md.cpt

mpirun -np 4 gmx mdrun -ntomp 12 -gpu_id 0234 -deffnm md -v -cpi md.cpt

nohup mpirun -np 4 gmx_mpi mdrun -ntomp 18 -gpu_id 0123 -deffnm md -multidir sim[0123] -plumed plumed.dat -v -replex 1000 &

mpirun -np 8 gmx_mpi mdrun -s md -plumed plumed.dat -gpu_id 00112233 -v -multi 8 -replex 100
