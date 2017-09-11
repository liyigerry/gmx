# install gromacs
[tutorial](http://www.gromacs.org/Documentation/Installation_Instructions_5.0)

## compiler & cmake
``` shell
sudo apt-get install build-essential cmake
```
### openmpi
``` shell
sudo apt-get install libopenmpi-dev openmpi-bin
```
### fftw
Please use the gromacs online installation reports fftw version.
``` shell
./configure CC='gcc' --enable-float --enable-threads --enable-shared -prefix=/vol6/home/shuqunliu/local/fftw/
```
or
``` shell
make -j 6
make install
```

### plumed
```
plumed patch -p --shared
```

### gromacs
#### dirty installation
``` shell
tar xvfz gromacs-5.0.4.tar.gz
cd gromacs-5.0.4
mkdir build
cd build
cmake .. -DCMAKE_PREFIX_PATH=/data/home/liushuqun/release/fftw:/data/home/liushuqun/release/openmpi -DCMAKE_C_COMPILER=/data/home/liushuqun/release/gcc -DCMAKE_CXX_COMPILER=/data/home/liushuqun/release/gcc -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=OFF -DGMX_MPI=ON -DCMAKE_INSTALL_PREFIX

cmake .. -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=OFF -DGMX_GPU=ON -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda -DNVML_INCLUDE_DIR=/usr/include/nvidia-375/-DGMX_MPI=ON -DNVML_LIBRARY=/usr/src/nvidia-375-375.66/ -DCMAKE_INSTALL_PREFIX

make
make check
sudo make install
source /usr/local/gromacs/bin/GMXRC
```
#### advanced installation
A shell script for [tianjian](www.nscc-tj.gov.cn) platform.
``` shell
CMAKE_PREFIX_PATH=/vol6/home/shuqunliu/local/fftw:/vol6/software/mpi \
cmake .. -DCMAKE_C_COMPILER=icc -DCMAKE_CXX_COMPILER=icpc \
-DREGRESSIONTEST_DOWNLOAD=OFF -DGMX_MPI=ON -DGMX_GPU=ON \
-DCUDA_TOOLKIT_ROOT_DIR=/vol-th/software/cuda \
-DCMAKE_INSTALL_PREFIX=/vol6/home/shuqunliu/local/gmx-5.0.4

CMAKE_PREFIX_PATH=/vol6/home/shuqunliu/local/fftw:/vol6/software/mpi \
cmake .. -DREGRESSIONTEST_DOWNLOAD=OFF -DGMX_MPI=ON \
-DGMX_GPU=ON -DGMC_CPU_ACCELERATION=NONE\
-DGMX_PREFER_STATIC_LIBS=ON -DBUILD_SHARED_LIBS=OFF\
-DCUDA_TOOLKIT_ROOT_DIR=/vol-th/software/cuda \
-DCMAKE_INSTALL_PREFIX=/vol6/home/shuqunliu/local/gmx-5.0.4
```

cmake .. -DCMAKE_PREFIX_PATH=/home/xiongwei/dusoftware/openmpi-1.10.0 -DFFTWF_LIBRARY=/home/xiongwei/dusoftware/fftw-3.3.4bbfftw3f.so -DFFTWF_INCLUDE_DIR=/home/xiongwei/dusoftware/fftw-3.3.4/include   -DGMX_MPI=ON -DCMAKE_INSTALL_PREFIX=/home/xiongwei/dusoftware/gromacs-5.0.6

cmake .. -DCMAKE_C_COMPILER=icc -DCMAKE_CXX_COMPILER=icpc -DBUILD_SHARED_LIBS=OFF -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=OFF -DGMX_MPI=ON -DCMAKE_INSTALL_PREFIX=/data/home/liushuqun/gerry/release/gromacs




