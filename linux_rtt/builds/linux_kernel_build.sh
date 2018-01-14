##### 在linux源码根目录文件夹下运行 #####

# 编译linux内核
export ARCH=arm  						# 指定核心类型
export CROSS_COMPILE=arm-linux-gnueabi- # 指定交叉编译前缀
make vexpress_defconfig					# 使用预配置文件
make zImage dtbs modules -j8			# 编译


# 拷贝生成的ZImag、dtbs 到单独的文件夹中
cp arch/arm/boot/zImage ../extra_folder/
cp arch/arm/boot/dts/*ca9.dtb ../extra_folder/

