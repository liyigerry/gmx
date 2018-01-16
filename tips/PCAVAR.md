
```
echo Protein-H Protein-H | gmx_mpi covar -f pro.xtc -s reference.pdb
```

```
gmx_mpi anaeig -v eigenvec.trr -first 1 -last 1 -s reference.pdb -comp -f pro.xtc
```

project out the part along a selected eigenvector:
```
echo Protein-H Protein-H | gmx_mpi anaeig -f pro.xtc -s reference.pdb -filt filter1.pdb -first 1 -last 1
```

extreme conformations sampled during the simulation along this eigenvector:
```
gmx_mpi anaeig -f morph.pdb -s m_3637_3j70.pdb -extr morph_extr1.pdb -first 1 -last 1
```


plumed driver --plumed pca_analysis.dat --mf_pdb trajectory.pdb
pca_analysis.dat
```
PCA METRIC=OPTIMAL ATOMS=1-470 NLOW_DIM=2 OFILE=pca-comp.pdb
```


pca_run.dat
```
PCAVARS REFERENCE=pca-comp.pdb TYPE=OPTIMAL LABEL=pc
meta: METAD ARG=pc.eig-1,pc.eig-2 ADAPTIVE=DIFF SIGMA=125 HEIGHT=2.4 TEMP=300 BIASFACTOR=12 PACE=10

PRINT ARG=pc.eig-1,pc.eig-2 STRIDE=1 FILE=colvar FMT=%8.4f
```
