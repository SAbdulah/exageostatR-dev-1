module load intel/2017
module load gcc
module load cmake/3.9.4/intel-2017
module load gsl/2.4/gnu-6.4.0
module load r/3.4.2

SETUP_DIR=$PWD
rm -rf exageostatr
MKLROOT=/sw/csi/intel/2017/compilers_and_libraries/linux/mkl
==============================
cd $SETUP_DIR
if [ ! -d "nlopt-2.4.2" ]; then
        wget http://ab-initio.mit.edu/nlopt/nlopt-2.4.2.tar.gz
        tar -zxvf nlopt-2.4.2.tar.gz
fi
cd nlopt-2.4.2
[[ -d nlopt_install ]] || mkdir nlopt_install
CC=gcc ./configure --prefix=$PWD/nlopt_install/ --enable-shared --without-guile
make -j
make -j install
NLOPTROOT=$PWD
export PKG_CONFIG_PATH=$NLOPTROOT/nlopt_install/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=$NLOPTROOT/nlopt_install/lib:$LD_LIBRARY_PATH
================================
cd $SETUP_DIR
if [  ! -d "hwloc-1.11.5" ]; then
        wget https://www.open-mpi.org/software/hwloc/v1.11/downloads/hwloc-1.11.5.tar.gz
        tar -zxvf hwloc-1.11.5.tar.gz
fi
cd hwloc-1.11.5
[[ -d hwloc_install ]] || mkdir hwloc_install
CC=gcc ./configure --prefix=$SETUP_DIR/hwloc-1.11.5/hwloc_install 
make -j
make -j install
HWLOCROOT=$PWD
export PKG_CONFIG_PATH=$HWLOCROOT/hwloc_install/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=$HWLOCROOT/hwloc_install/lib:$LD_LIBRARY_PATH
================================
cd $SETUP_DIR
if [ ! -d "starpu-1.2.6" ]; then
        wget http://starpu.gforge.inria.fr/files/starpu-1.2.6/starpu-1.2.6.tar.gz
        tar -zxvf starpu-1.2.6.tar.gz
fi
cd starpu-1.2.6
[[ -d starpu_install ]] || mkdir starpu_install
 ./configure --prefix=$SETUP_DIR/starpu-1.2.6/starpu_install  -disable-cuda --disable-opencl --with-mpicc=/opt/share/intel/2017/compilers_and_libraries/linux/mpi/intel64/bin/mpicc
make -j
make -j  install
STARPUROOT=$PWD
export PKG_CONFIG_PATH=$STARPUROOT/starpu_install/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=$STARPUROOT/starpu_install/lib:$LD_LIBRARY_PATH
#************************************************************************ Install Chameleon - Stars-H - HiCMA 
cd $SETUP_DIR
# Check if we are already in exageostat repo dir or not.
if git -C $PWD remote -v | grep -q 'https://github.com/ecrc/exageostatr'
then
        # we are, lets go to the top dir (where .git is)
        until test -d $PWD/.git ;
        do
                cd ..
        done;
else
        git clone https://github.com/ecrc/exageostatr
        cd exageostatr
fi
git pull
git submodule update --init --recursive

export EXAGEOSTATDEVDIR=$PWD/src
cd $EXAGEOSTATDEVDIR
export HICMADIR=$EXAGEOSTATDEVDIR/hicma
export CHAMELEONDIR=$EXAGEOSTATDEVDIR/hicma/chameleon
export STARSHDIR=$EXAGEOSTATDEVDIR/stars-h

## STARS-H
cd $STARSHDIR
rm -rf build
mkdir -p build
cd build/install_dir
CC=gcc cmake .. -DCMAKE_INSTALL_PREFIX=$STARSHDIR/install_dir -DMPI=OFF -DOPENMP=OFF -DSTARPU=OFF -DCMAKE_C_FLAGS="-fPIC"
make -j
make install

export PKG_CONFIG_PATH=$STARSHDIR/install_dir/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=$STARSHDIR/install_dir/lib/pkgconfig:$LD_LIBRARY_PATH
## CHAMELEON
cd $CHAMELEONDIR
rm -rf build
mkdir -p build/install_dir
cd build


CC=gcc cmake .. -DCMAKE_INSTALL_PREFIX=$PWD/install_dir -DCMAKE_COLOR_MAKEFILE:BOOL=ON -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON -DBUILD_SHARED_LIBS=ON -DCHAMELEON_ENABLE_EXAMPLE=ON -DCHAMELEON_ENABLE_TESTING=ON -DCHAMELEON_ENABLE_TIMING=ON -DCHAMELEON_USE_MPI=ON -DCHAMELEON_USE_CUDA=OFF -DCHAMELEON_USE_MAGMA=OFF -DCHAMELEON_SCHED_QUARK=OFF -DCHAMELEON_SCHED_STARPU=ON -DCHAMELEON_USE_FXT=OFF -DSTARPU_DIR=$STARPUROOT/starpu_install -DBLAS_LIBRARIES="-L${MKLROOT}/lib;-lmkl_intel_lp64;-lmkl_core;-lmkl_sequential;-lpthread;-lm;-ldl" -DBLAS_COMPILER_FLAGS="-m64;-I${MKLROOT}/include" -DLAPACK_LIBRARIES="-L${MKLROOT}/lib;-lmkl_intel_lp64;-lmkl_core;-lmkl_sequential;-lpthread;-lm;-ldl" -DCBLAS_DIR="${MKLROOT}" -DLAPACKE_DIR="${MKLROOT}" -DTMG_DIR="${MKLROOT}" -DMORSE_VERBOSE_FIND_PACKAGE=ON -DMPI_C_COMPILER=/opt/share/intel/2017/compilers_and_libraries/linux/mpi/intel64/bin/mpicc


make -j # CHAMELEON parallel build seems to be fixed
make install

export PKG_CONFIG_PATH=$CHAMELEONDIR/install_dir/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=$CHAMELEONDIR/install_dir/lib/:$LD_LIBRARY_PATH


## HICMA
cd $HICMADIR
rm -rf build
mkdir -p build
cd build
===============

CC=gcc cmake .. -DCMAKE_INSTALL_PREFIX=$PWD/install_dir -DCMAKE_COLOR_MAKEFILE:BOOL=ON -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON -DBUILD_SHARED_LIBS=ON -DHICMA_USE_MPI=ON  -DSTARPU_DIR=$STARPUROOT/starpu_install -DBLAS_LIBRARIES="-L${MKLROOT}/lib;-lmkl_intel_lp64;-lmkl_core;-lmkl_sequential;-lpthread;-lm;-ldl" -DBLAS_COMPILER_FLAGS="-m64;-I${MKLROOT}/include" -DLAPACK_LIBRARIES="-L${MKLROOT}/lib;-lmkl_intel_lp64;-lmkl_core;-lmkl_sequential;-lpthread;-lm;-ldl" -DCBLAS_DIR="${MKLROOT}" -DLAPACKE_DIR="${MKLROOT}" -DTMG_DIR="${MKLROOT}" -DMORSE_VERBOSE_FIND_PACKAGE=ON -DMPI_C_COMPILER=/opt/share/intel/2017/compilers_and_libraries/linux/mpi/intel64/bin/mpicc

make -j
make install

export PKG_CONFIG_PATH=$HICMADIR/install_dir/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=$HICMADIR/install_dir/lib/:$LD_LIBRARY_PATH

$SETUP_DIR
#export CPATH=$CPATH:/usr/local/include/coreblas && \
#export LD_LIBRARY_PATH="${MKLROOT}/lib/intel64_lin:$LD_LIBRARY_PATH" && \
#export LIBRARY_PATH="$LD_LIBRARY_PATH"

## Modify src/Makefile, compilation flagss -> flagsl

