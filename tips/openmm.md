install
```
conda install -c omnia openmm
```

verify
```
python -m simtk.testInstallation
```

plumed install
```
ccmake .. -DOPENMM_DIR=/home/liyi/.conda/envs/env -DPLUMED_INCLUDE_DIR=/home/liyi/release/plumed2.3/include/plumed -DPLUMED_LIBRARY_DIR=/home/liyi/release/plumed2.3/lib -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda-8.0 -DCMAKE_INSTALL_PREFIX=/home/liyi/.conda/envs/env/
```

find the right path
`conda list openmm`

plumed test
```
from openmmplumed import PlumedForce
```

