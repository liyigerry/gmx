# metadynamics

## online docs
[plumed](http://plumed.github.io/doc-v2.2/user-doc/html/index.html)

## collective variables CVs
CVs是由atoms定义而来的。
In all the CVs, one should specify the atoms involved in it.
所以，要注意atom indexing。

## 调用plumed
gromacs，配置文件习惯命名为plumed.dat.
```
mdrun -plumed plumed.dat
```

## CVs语法
syntax for collective variables, or a typical plumed.dat.
1. specification of CVs.
2. operation.
3. print out items and frequency, default out file COLVAR.
4. termination line: ENDMETA

## 理解CVs
CVs是分析导数？。在模拟过程中，通过对CVs添加偏倚势？偏移势来间接影响整个模拟系统。怎么影响？
The CVs implemented in plumed has analytical derivatives and, by biasing the value of a single CV, one turns to affect the time evolution of the system itself.

## 选择CVs
choosing CVs wisely, CVs should:
1. clearly distinguish between the initial state, the final state and the intermediates.
2. describe all slow events that are relevant to the process of interest.
3. limited number.

## META的原理
adds an external potential (Gaussian function) to the simulation.
这里有公式

## META的一般步骤
1. 选择CVs。choosing CVs.
2. 选择高斯高度（HEIGHT）和沉积步幅(W_STRIDE)。choosing the Gaussian height and the deposition stride.
3. 选择高斯宽度(SIGMA)。choosing the Gaussian width.
```
HILLS W_STRIDE 1000 HEIGHT 0.4
TORSION LIST 5 7 9 15 SIGMA 0.35
ENDMETA
```

## Well-tempered(WT) META
The Gaussian height is automatically rescaled during simulation.
~~这里有公式~~

## path CVs
are very useful whenever one  wants to find an optimal free energy channel connecting two specific regions in the phase space and calculate the associated free energy profile.

A given point in Cartesian space corresponds to a vector in the coarse grained space.
coarse grained space
For example, in a chemical reaction it might turn to be useful to describe the process in terms of some H-bond distance and sepecific angles.
In plumed, one can use RMSD as coarse grained space.
In RMSD the representation of configuration is done in terms of explicit Cartesion coordinates of subset of atoms involved in the CVs.

Z(x), S(x) return the projection of the current phase-space vector on the reference path.
径向，切向

reference.pdb
the last column of the pdb (generally beta and occupancy) are here in plumed used to specify the weight to use in the alignment and displacement.

## MSMs处理metadyanimcs的关键问题就是n on-equilibrium与equilibrium的关系.
