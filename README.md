# sabrina-linux

## setup
```
# apt install gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu
```
For building DTB, variable **DTIMGTOOL** in *build_kernel.sh* script must contain the path for tool [mkdtboimg.py](https://android.googlesource.com/platform/system/libufdt/+/refs/heads/master/utils/src/mkdtboimg.py).

## build
```
$ build_kernel.sh sabrina .
```
or (but no dtb generation):
```
$ make CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 sabrina_defconfig
$ make CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 -j8 CONFIG_DEBUG_SECTION_MISMATCH=y
```
