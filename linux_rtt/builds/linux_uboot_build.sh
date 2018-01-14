##### 在uboot文件夹下执行 #####

# 编译u-boot
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabi-
make vexpress_ca9x4_defconfig
make -j8

# 拷贝生成文件到目标文件夹
cp u-boot ../extra_folder

# 将zImage转换为uImage格式
cd tools
./mkimage -n 'Cortex-A9' -A arm -O linux -T kernel -C none -a 0x60003000 -e 0x60003000 -d ../../extra_folder/zImage ../../extra_folder/uImage
cd ../../

