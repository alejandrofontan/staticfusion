#!/bin/bash

delete_if_exists() {
  local folder=$1
  build_folder="${folder}/build"
  bin_folder="${folder}/bin"
  lib_folder="${folder}/lib"
  if [ -d "$build_folder" ]; then
    rm -rf "$build_folder"
  fi
  if [ -d "$bin_folder" ]; then
    rm -rf "$bin_folder"
  fi
  if [ -d "$lib_folder" ]; then
    rm -rf "$lib_folder"
  fi
}

build_library() {
  library_name="$1"
  source_folder="$2"
  verbose="$3"
  force_build="$4"

  build_folder="$source_folder/build"
  bin_folder="$source_folder/bin"
  lib_folder="$source_folder/lib"

  if [ "$force_build" = true ]; then
  	delete_if_exists ${source_folder}
  fi

  if [ "$verbose" = true ]; then
    echo "[StaticFusion][build.sh] Compile ${library_name} ... "
    mkdir ${build_folder} && mkdir ${bin_folder}
    cmake -S ${source_folder} -B ${build_folder} -DCMAKE_INSTALL_PREFIX=${bin_folder}
    cd ${build_folder}
    make -j8
    make install
  else
    echo "[StaticFusion][build.sh] Compile ${library_name} (output disabled) ... "
    mkdir ${build_folder} && mkdir ${bin_folder}
    cmake -S ${source_folder} -B ${build_folder} -DCMAKE_INSTALL_PREFIX=${bin_folder} > /dev/null 2>&1
    cd ${build_folder}
    make -j8 > /dev/null 2>&1
    make install > /dev/null 2>&1
  fi
}

# Check inputs
force_build=false
verbose=false
for input in "$@"
do
    if [ "$input" = "-f" ]; then
  	force_build=true
    fi
    if [ "$input" = "-v" ]; then
  	verbose=true
    fi
done

# Baseline Dir
LIBRARY_PATH=$(realpath "$0")
LIBRARY_DIR=$(dirname "$LIBRARY_PATH")

## Build mrpt
library_name="mrpt"
source_folder="${LIBRARY_DIR}/${library_name}"
git clone https://github.com/MRPT/mrpt.git
build_library ${library_name} ${source_folder} ${verbose} ${force_build}

## Build Pangolin
library_name="Pangolin"
source_folder="${LIBRARY_DIR}/${library_name}"
git clone --recursive https://github.com/stevenlovegrove/Pangolin.git
build_library ${library_name} ${source_folder} ${verbose} ${force_build}

## Build Static Fusion
library_name="staticfusion"
source_folder="${LIBRARY_DIR}"
build_library ${library_name} ${source_folder} ${verbose} ${force_build}