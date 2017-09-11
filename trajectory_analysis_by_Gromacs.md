trajectory_analysis_by_Gromacs.md

# 使用Gromacs分析轨迹

## 骨架原子相对于初始结构的RMSD
echo Backbone Backbone | gmx rms -f md.xtc -s reference.tpr -o rmsd.xvg

## 截取平衡轨迹
gmx trjconv -f md.xtc -s md.tpr -o equilibrium.xtc -b start_frame
组合平衡轨迹
gmx trjcat -f [equilibrium.xtc] -o equilibrium_combine.xtc -settime

## 计算组合平衡轨迹的RMSF
echo C-alpha | gmx rmsf -f equilibrium_combine.xtc -s reference.tpr -o rmsf.xvg -ox average.pdb -res -oq bfactor.pdb

## 计算平衡轨迹的结构属性
### 氢键：
gmx hbond -f equilibrium_combine.xtc -s reference.tpr -num hbnum.xvg -g hbond.log -hbn hbond.ndx
1
1
gmx analyze -f num.xvg

### 溶剂可及性表面积：
gmx sasa -f equilibrium_combine.xtc -s reference.tpr -o area.xvg -oa atomarea.xvg -or resarea.xvg
1
gmx analyze -f resarea.xvg

### 天然接触
gmx mindist -f equilibrium_combine.xtc -s reference.tpr -od mindist.xvg -on numcont.xvg -o atompair.out -or mindistres.xvg
1
1
gmx analyze -f numcont.xvg

### 回旋半径
gmx gyrate -f equilibrium_combine.xtc -s reference.tpr -o gyrate.xvg
1
gmx analyze -f gyrate.xvg
  
### 二级结构含量
gmx do_dssp -f equilibrium_combine.xtc -s reference.tpr -ssdump dump.dat -map ss.map -sc sc.xvg -o ss.xpm 
1
gmx xpm2ps -f ss.xpm -di md.m2p -o ss.eps2

## 平衡轨迹本质动力学分析

### 生成协方差矩阵
gmx covar -f equilibrium_combine.xtc -s reference.tpr -o eigen.xvg -v eigen.trr -l covar.log -xpm covar.xpm -xpma covara.xpm

### 分析特征向量并生成极端结构
gmx anaeig -v eigen.trr -f equilibrium_combine.xtc -s reference.tpr -comp eigcomp.xvg -rmsf eigrmsf.xvg -proj proj.xvg -extr extreme.pdb -first 1 -last 4 -nframes 2

### cosine含量分析
gmx analyze -f proj.xvg -cc coscont.xvg

### 内插图
gmx anaeig -s average.pdb -f equilibrium_combine.xtc -v eigen.trr -eig eigen.xvg -comp combinecomp.xvg -rmsf combinermsf.xvg -proj combineproj.xvg -first 1 -last 30 -nframes 30 -entropy
