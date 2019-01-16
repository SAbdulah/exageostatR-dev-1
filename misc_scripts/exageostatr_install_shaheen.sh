module load cmake/3.10.2
export LC_ALL=en_US.UTF-8
export CRAYPE_LINK_TYPE=dynamic
module switch PrgEnv-cray PrgEnv-gnu
#module load gsl/2.4
#module load cray-netcdf
#module load cray-hdf5
#Intel MKL:
#==========
module load intel/18.0.1.163

cd ..
git submodule update --init
cd ..
mkdir installation_dir
cd installation_dir
SETUP_DIR=$PWD
rm -rf *
==============================
cd $SETUP_DIR
if [ ! -d "nlopt-2.4.2" ]; then
        wget http://ab-initio.mit.edu/nlopt/nlopt-2.4.2.tar.gz
        tar -zxvf nlopt-2.4.2.tar.gz
fi
cd nlopt-2.4.2

[[ -d nlopt_install ]] || mkdir nlopt_install

CC=gcc ./configure --prefix=$PWD/install_dir/ --enable-shared --without-guile
	
make -j
make -j install
NLOPTROOT=$PWD
export PKG_CONFIG_PATH=$NLOPTROOT/install_dir/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=$NLOPTROOT/install_dir/lib:$LD_LIBRARY_PATH

echo 'export PKG_CONFIG_PATH='$NLOPTROOT'/install_dir/lib/pkgconfig:$PKG_CONFIG_PATH' >>  $SETUP_DIR/pkg_config.sh
echo 'export LD_LIBRARY_PATH='$NLOPTROOT'/install_dir/lib:$LD_LIBRARY_PATH' >>  $SETUP_DIR/pkg_config.sh
#export CPATH=$NLOPTROOT/install_dir/include:$CPATH
================================
cd $SETUP_DIR
if [  ! -d "hwloc-2.0.2" ]; then
        wget https://download.open-mpi.org/release/hwloc/v2.0/hwloc-2.0.2.tar.gz
        tar -zxvf hwloc-2.0.2.tar.gz
fi
cd hwloc-2.0.2
[[ -d hwloc_install ]] || mkdir hwloc_install
CC=cc CXX=CC ./configure --prefix=$PWD/hwloc_install --disable-libxml2 -disable-pci --enable-shared=yes

make -j
make -j install
HWLOCROOT=$PWD
export PKG_CONFIG_PATH=$HWLOCROOT/hwloc_install/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=$HWLOCROOT/hwloc_install/lib:$LD_LIBRARY_PATH

echo 'export PKG_CONFIG_PATH='$HWLOCROOT'/hwloc_install/lib/pkgconfig:$PKG_CONFIG_PATH' >>  $SETUP_DIR/pkg_config.sh
echo 'export LD_LIBRARY_PATH='$HWLOCROOT'/hwloc_install/lib:$LD_LIBRARY_PATH' >>  $SETUP_DIR/pkg_config.sh
================================
cd $SETUP_DIR
if [ ! -d "starpu-1.2.6" ]; then
        wget http://starpu.gforge.inria.fr/files/starpu-1.2.6/starpu-1.2.6.tar.gz
        tar -zxvf starpu-1.2.6.tar.gz
fi
cd starpu-1.2.6
[[ -d starpu_install ]] || mkdir starpu_install
CFLAGS=-fPIC CXXFLAGS=-fPIC CC=cc CXX=CC FC=ftn ./configure --prefix=$PWD/starpu_install/ --disable-cuda --disable-opencl --with-mpicc=/opt/cray/pe/craype/2.5.13/bin/cc --enable-shared --disable-build-doc --disable-export-dynamic --disable-mpi-check
make -j
make -j  install
STARPUROOT=$PWD
export PKG_CONFIG_PATH=$STARPUROOT/starpu_install/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=$STARPUROOT/starpu_install/lib:$LD_LIBRARY_PATH
export CPATH=$STARPUROOT/starpu_install/include:$CPATH
echo 'export PKG_CONFIG_PATH='$STARPUROOT'/starpu_install/lib/pkgconfig:$PKG_CONFIG_PATH' >>  $SETUP_DIR/pkg_config.sh
echo 'export LD_LIBRARY_PATH='$STARPUROOT'/starpu_install/lib:$LD_LIBRARY_PATH' >>  $SETUP_DIR/pkg_config.sh
echo 'export CPATH='$STARPUROOT'/starpu_install/include:$CPATH' >>  $SETUP_DIR/pkg_config.sh
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
mkdir -p build/install_dir
cd build
CFLAGS=-fPIC cmake .. -DCMAKE_CXX_COMPILER=CC -DCMAKE_C_COMPILER=cc -DCMAKE_Fortran_COMPILER=ftn -DCMAKE_INSTALL_PREFIX=$PWD/install_dir -DMPI=OFF -DOPENMP=OFF -DSTARPU=ON -DBLAS_LIBRARIES="-Wl,--no-as-needed;-L${MKLROOT}/lib;-lmkl_intel_lp64;-lmkl_core;-lmkl_sequential;-lpthread;-lm;-ldl" -DBLAS_COMPILER_FLAGS="-m64;-I${MKLROOT}/include" -DLAPACK_LIBRARIES="-Wl,--no-as-needed;-L${MKLROOT}/lib;-lmkl_intel_lp64;-lmkl_core;-lmkl_sequential;-lpthread;-lm;-ldl" -DCBLAS_DIR="${MKLROOT}" -DLAPACKE_DIR="${MKLROOT}" -DTMG_DIR="${MKLROOT}"  -DEXAMPLES=OFF -DTESTING=OFF -DBUILD_SHARED_LIBS=ON

make -j
make install
export PKG_CONFIG_PATH=$STARSHDIR/build/install_dir/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=$STARSHDIR/build/install_dir/lib:$LD_LIBRARY_PATH

echo 'export PKG_CONFIG_PATH='$STARSHDIR'/build/install_dir/lib/pkgconfig:$PKG_CONFIG_PATH' >>  $SETUP_DIR/pkg_config.sh
echo 'export LD_LIBRARY_PATH='$STARSHDIR'/build/install_dir/lib:$LD_LIBRARY_PATH' >>  $SETUP_DIR/pkg_config.sh

## CHAMELEON
cd $CHAMELEONDIR
rm -rf build
mkdir -p build/install_dir
cd build


LDFLAGS=-lrt cmake .. -DCMAKE_CXX_COMPILER=CC -DCMAKE_C_COMPILER=cc -DCMAKE_Fortran_COMPILER=ftn -DCMAKE_INSTALL_PREFIX=$PWD/install_dir -DCMAKE_COLOR_MAKEFILE:BOOL=ON -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON -DBUILD_SHARED_LIBS=ON -DCHAMELEON_ENABLE_EXAMPLE=ON -DCHAMELEON_ENABLE_TESTING=ON -DCHAMELEON_ENABLE_TIMING=ON -DCHAMELEON_USE_MPI=ON -DCHAMELEON_USE_CUDA=OFF -DCHAMELEON_USE_MAGMA=OFF -DCHAMELEON_SCHED_QUARK=OFF -DCHAMELEON_SCHED_STARPU=ON -DCHAMELEON_USE_FXT=OFF -DSTARPU_DIR=$STARPUROOT/starpu_install -DBLAS_LIBRARIES="-Wl,--no-as-needed;-L${MKLROOT}/lib;-lmkl_intel_lp64;-lmkl_core;-lmkl_sequential;-lpthread;-lm;-ldl" -DBLAS_COMPILER_FLAGS="-m64;-I${MKLROOT}/include" -DLAPACK_LIBRARIES="-Wl,--no-as-needed;-L${MKLROOT}/lib;-lmkl_intel_lp64;-lmkl_core;-lmkl_sequential;-lpthread;-lm;-ldl" -DCBLAS_DIR="${MKLROOT}" -DLAPACKE_DIR="${MKLROOT}" -DTMG_DIR="${MKLROOT}" -DMORSE_VERBOSE_FIND_PACKAGE=ON -DMPI_C_COMPILER=/opt/cray/pe/craype/2.5.13/bin/cc

make -j # CHAMELEON parallel build seems to be fixed
make install

export PKG_CONFIG_PATH=$CHAMELEONDIR/build/install_dir/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=$CHAMELEONDIR/build/install_dir/lib/:$LD_LIBRARY_PATH
export CPATH=$CHAMELEONDIR/build/install_dir/include/coreblas:$CPATH

echo 'export PKG_CONFIG_PATH='$CHAMELEONDIR'/build/install_dir/lib/pkgconfig:$PKG_CONFIG_PATH' >>  $SETUP_DIR/pkg_config.sh
echo 'export LD_LIBRARY_PATH='$CHAMELEONDIR'/build/install_dir/lib:$LD_LIBRARY_PATH' >>  $SETUP_DIR/pkg_config.sh
echo 'export CPATH='$CHAMELEONDIR'/build/install_dir/include/coreblas:$CPATH' >>  $SETUP_DIR/pkg_config.sh

## HICMA
cd $HICMADIR
rm -rf build
mkdir -p build/install_dir
cd build
===============

cmake .. -DCMAKE_CXX_COMPILER=CC -DCMAKE_C_COMPILER=cc -DCMAKE_Fortran_COMPILER=ftn -DCMAKE_INSTALL_PREFIX=$PWD/install_dir -DHICMA_USE_MPI=1 -DCMAKE_COLOR_MAKEFILE:BOOL=ON -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON -DBUILD_SHARED_LIBS=ON  -DSTARPU_DIR=$STARPUROOT/starpu_install -DBLAS_LIBRARIES="-Wl,--no-as-needed;-L${MKLROOT}/lib;-lmkl_intel_lp64;-lmkl_core; -lmkl_sequential;-lpthread;-lm;-ldl" -DBLAS_COMPILER_FLAGS="-m64;-I${MKLROOT}/include" -DLAPACK_LIBRARIES="-Wl,--no-as-needed;-L${MKLROOT}/lib;-lmkl_intel_lp64;-lmkl_core; -lmkl_sequential;-lpthread; -lm;-ldl" -DCBLAS_DIR="${MKLROOT}" -DLAPACKE_DIR="${MKLROOT}" -DTMG_DIR="${MKLROOT}" -DMPI_C_COMPILER=/opt/cray/pe/craype/2.5.13/bin/cc

make -j
make install

export PKG_CONFIG_PATH=$HICMADIR/build/install_dir/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=$HICMADIR/build/install_dir/lib/:$LD_LIBRARY_PATH
echo 'export PKG_CONFIG_PATH='$HICMADIR'/build/install_dir/lib/pkgconfig:$PKG_CONFIG_PATH' >>  $SETUP_DIR/pkg_config.sh
echo 'export LD_LIBRARY_PATH='$HICMADIR'/build/install_dir/lib:$LD_LIBRARY_PATH' >>  $SETUP_DIR/pkg_config.sh

cd $SETUP_DIR
#export CPATH=$CPATH:/usr/local/include/coreblas && \
#export LD_LIBRARY_PATH="${MKLROOT}/lib/intel64_lin:$LD_LIBRARY_PATH" && \
#export LIBRARY_PATH="$LD_LIBRARY_PATH"

## Modify src/Makefile, compilation flagss -> flagsl
module load gsl/2.4
echo 'module load  cmake/3.10.2' >> $SETUP_DIR/pkg_config.sh
echo 'export LC_ALL=en_US.UTF-8' >> $SETUP_DIR/pkg_config.sh
echo 'export CRAYPE_LINK_TYPE=dynamic' >> $SETUP_DIR/pkg_config.sh
echo 'module switch PrgEnv-cray PrgEnv-gnu' >> $SETUP_DIR/pkg_config.sh
echo 'module load  intel/18.0.1.163' >> $SETUP_DIR/pkg_config.sh
echo 'module load  gsl/2.4' >> $SETUP_DIR/pkg_config.sh
cd ..
#module load R
#mkdir install_dir
#R CMD build exageostatR-dev
#R CMD INSTALL exageostat-1.0.0.tar.gz -l ./install_dir