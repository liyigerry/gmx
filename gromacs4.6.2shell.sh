#!/bin/bash
#This script needs to be edited for each run.
#Define PDB Filename & GROMACS Pameters
NAME="1IC6"
FORCEFIELD="gromos43a1"
WATERMODEL="SPC"
WATERTOPFILE="spc216.gro"
BOXTYPE="cubic"
#Setup GROMACS Job. Probably not necessary to edit past this point.
# if [ -z "$NAME" ]; then
#     echo "USAGE: ./setup_job.sh pdb_filename"
#     echo "Do NOT include the .pdb extension in the file name."
#     exit
# fi
# link GROMACS environment
source /home/bioinformatics/software/gromacs-4.6.2/install_dir/bin/GMXRC
# Create symlinks to MDP files
# find  '../MDP_Files' -name '*.mdp' -exec ln -s {} . \;
# minim.mdp
# nvt.mdp
# npt.mdp
# md.mdp
# generate GROMACS .gro file
pdb2gmx_mpi -f $NAME.pdb -o $NAME.gro -ff $FORCEFIELD -water $WATERMODEL -ignh -p $NAME.top
# define the box
editconf_mpi -f $NAME.gro -o $NAME-box.gro  -d 1.4 -bt $BOXTYPE

# add solvate

genbox_mpi  -cp $NAME-box.gro -cs $WATERTOPFILE -o $NAME-water.gro -p $NAME.top
# energy minimization of the structure in solvate

grompp_mpi -f em_1.mdp -c $NAME-water.gro -p $NAME.top -o $NAME-em_1.tpr

mpirun -n 4 mdrun_mpi -v -deffnm $NAME-em_1 -npme 1
grompp_mpi -f em_2.mdp -c $NAME-em_1.gro -p $NAME.top -o $NAME-em_2.tpr
mpirun -n 4  mdrun_mpi -v -deffnm $NAME-em_2 -npme 1
# cen=0.15
echo 15 | genion_mpi -s $NAME-em_2.tpr -o $NAME-em_2.gro -neutral -conc 0.15 -g genion.log -p topol.top
grompp_mpi -f em_3.mdp -c $NAME-em_2.gro -p topol.top -o $NAME-em_3.tpr
mpirun -n 4  mdrun_mpi -v -deffnm $NAME-em_3 -npme 1
# vpt
grompp_mpi -f vpt.mdp -c $NAME-em_3.gro -t vpt.cpt -p $NAME.top -o vpt.tpr
mpirun -n 4  mdrun_mpi -v -deffnm vpt -npme 1
# pr_npt
grompp_mpi -f pr_npt.mdp -c vpt.gro -t pr_npt.cpt -p $NAME.top -o pr_npt.tpr
mpirun -n 4  mdrun_mpi -v -deffnm pr_npt -npme 1
# md.npt
grompp_mpi -f md.mdp -c pr_npt.gro -t md.cpt -p $NAME.top -o md.tpr
mpirun -n 4  mdrun_mpi -v -deffnm md -npme 1
