#!/bin/bash

LIBRARY_PATH=$PREFIX/lib
INCLUDE_PATH=$PREFIX/include

if [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  if [ $ARCH -eq 64 ]; then
    VL_ARCH="glnxa64"
  else
    VL_ARCH="glnx86"
  fi
  DYNAMIC_EXT="so"
  DISABLE_OPENMP=0
fi
if [ "$(uname -s)" == "Darwin" ]; then
  VL_ARCH="maci64"
  DYNAMIC_EXT="dylib"
  # OpenMP isn't supported on clang at this time
  DISABLE_OPENMP=1
fi

export CFLAGS="-I$INCLUDE_PATH -DVL_DISABLE_OPENMP=$DISABLE_OPENMP"
export LDFLAGS="-L$LIBRARY_PATH"

# Turn off all optimisations. Use vlfeat_avx for a fast version
make MEX="" NO_TESTS=yes ARCH=${VL_ARCH} DISABLE_OPENMP=$DISABLE_OPENMP -j${CPU_COUNT}

# On OSX the resolution of the libvl.dylib doesn't seem to
# work properly for the executables - but they are properly
# relatively linked using @loader_path, therefore, copy
# the dylib into bin so they work properly.
if [ "$(uname -s)" == "Darwin" ]; then
  mkdir -p $PREFIX/bin/
  cp bin/${VL_ARCH}/libvl.${DYNAMIC_EXT} $PREFIX/bin/
fi

mkdir -p $PREFIX/bin
cp bin/${VL_ARCH}/sift $PREFIX/bin/
cp bin/${VL_ARCH}/mser $PREFIX/bin/
cp bin/${VL_ARCH}/aib $PREFIX/bin/

mkdir -p $LIBRARY_PATH
cp bin/${VL_ARCH}/libvl.${DYNAMIC_EXT} $LIBRARY_PATH/

mkdir -p $INCLUDE_PATH/vl
cp vl/*.h $INCLUDE_PATH/vl

