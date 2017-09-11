#!/bin/bash
#This script needs to be edited for each run.
#Define PDB Filename & GROMACS Pameters
NAME=$1
FORCEFIELD="amber99sb-ildn"
WATERMODEL="tip3p"
WATERTOPFILE="spc216.gro"
BOXTYPE="dodecahedron"
BOXORIENTATION="1.0"
BOXSIZE="5.0"
BOXCENTER="2.5"
source /usr/local/gromacs/bin/GMXRC
# generate GROMACS .gro file
gmx_mpi pdb2gmx -f $NAME.pdb -o $NAME.gro -ff $FORCEFIELD -water $WATERMODEL -ignh -p topol.top
# define the box
gmx_mpi editconf -f $NAME.gro -o $NAME_box.gro -bt $BOXTYPE -c -d $BOXORIENTATION
# energy minimization of the structure in vacuum
gmx_mpi grompp -f minim.mdp -c $NAME_box.gro -p topol.top -o em-vacuum.tpr
# add solvate
gmx_mpi solvate -cp $NAME_box.gro -cs $WATERTOPFILE -o $NAME_solv.gro -p topol.top
# add icons
gmx_mpi grompp -f ions.mdp -c $NAME_solv.gro -p topol.top -o ions.tpr
echo SOL | gmx_mpi genion -s ions.tpr -o $NAME_solv_ions.gro -p topol.top -pname NA -nname CL -conc 0.1 -neutral
# energy minimization of the structure in solvate
gmx_mpi grompp -f minim.mdp -c $NAME_solv_ions.gro -p topol.top -o em.tpr
gmx_mpi mdrun -v -deffnm em
# nvt
gmx_mpi grompp -f nvt.mdp -c em.gro -p topol.top -o nvt.tpr
gmx_mpi mdrun -v -deffnm nvt
# npt
gmx_mpi grompp -f npt.mdp -c nvt.gro -t nvt.cpt -p topol.top -o npt.tpr
gmx_mpi mdrun -v -deffnm npt
# md
gmx_mpi grompp -f md.mdp -c npt.gro -t npt.cpt -p topol.top -o md.tpr