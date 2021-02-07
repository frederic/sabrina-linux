#!/bin/bash

exec_name=$0

set -o errtrace
function err() {
  echo "Fatal error: script ${exec_name} aborting at line $LINENO," \
    "command \"$BASH_COMMAND\" returned $?"
  exit 1
}
trap err ERR

readonly kernel_dir=.
readonly product=$1
readonly workspace_path=$2
readonly bootdir=./arch/arm64/boot
DTIMGTOOL=../sdk/tools/mkdtimg

arch=arm64
cross_compile=../prebuilt/toolchain/aarch64/bin/aarch64-cros-linux-gnu-
cpu_num=$(grep -c processor /proc/cpuinfo)

function usage(){
  echo "Usage: ${exec_name} <product> [workspace path]"
  echo "supported products: sabrina"
  echo "Note: if [workspace path] is not set, it still builds"
}

function run_kernel_make(){
  echo "***** building $4 *****"
  make CROSS_COMPILE=$1 ARCH=$3 -j$2 $4 CONFIG_DEBUG_SECTION_MISMATCH=y
  echo "**** completed building $4 *****"
}

function build_kernel(){
  local kernel_path=$(readlink -f $1)
  local defconfig_file_name=$2

  # If it is b series board, use bx defconfig.
  local board_type=`echo ${defconfig_file_name} | cut -d "-" -f2 | cut -c 1`
  if [[ "$board_type" == "b" ]]; then
    local product_surname=`echo ${defconfig_file_name} | cut -d "-" -f1`
    defconfig_file_name=${product_surname}-bx_defconfig
  fi

  pushd $kernel_path

  # Make a clean build and check .config and defconfig if different then abort.
  make clean
  run_kernel_make $cross_compile $cpu_num $arch $defconfig_file_name
  diff .config arch/arm64/configs/${defconfig_file_name}

  run_kernel_make $cross_compile $cpu_num $arch all

  popd
}

function build_dtb(){
  local kernel_path=$(readlink -f $1)
  local dtb_file_name=$2

  pushd $kernel_path
  run_kernel_make $cross_compile $cpu_num $arch $dtb_file_name
  popd
}

if (( $# < 1 ))
then
  usage
  exit 2
fi

case $product in
  sabrina)
    ;;
  *)
    echo "unknown product: $product"
    exit 1
esac

build_kernel ${kernel_dir} sabrina_defconfig

dtb_file_name=sm1_s905d3_sabrina.dtb
dtbo_file_name=android_p_overlay_dt.dtb
path_to_dtb_file=arch/arm64/boot/dts/amlogic/${dtb_file_name}
path_to_dtbo_file=arch/arm64/boot/dts/amlogic/${dtbo_file_name}

build_dtb ${kernel_dir} ${dtb_file_name}
build_dtb ${kernel_dir} ${dtbo_file_name}

if [ ! -z $workspace_path ]; then
  prebuilt_path=${workspace_path}/device/google/${product}-kernel
  mkdir -p ${prebuilt_path}
  cp ${bootdir}/Image.gz ${prebuilt_path}
  cp ${path_to_dtb_file} ${prebuilt_path}/sabrina.dtb
  $DTIMGTOOL create ${prebuilt_path}/dtbo.img ${path_to_dtbo_file}
else
  echo "no workspace path"
fi
