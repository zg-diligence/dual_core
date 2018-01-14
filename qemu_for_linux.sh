##### 1.prepare for compiling linux #####

# 下载linux4.4源码
wget https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.4.1.tar.xz
tar -jxvf linux-4.4.1.tar.xz

# 下载busybox源码
wget http://www.busybox.net/downloads/busybox-1.25.1.tar.bz2
tar -jxvf busybox-1.25.1.tar.bz2

# 安装arm交叉编译链、qemu模拟器
sudo apt-get install gcc-arm-linux-gnueabi
sudo apt-get install qemu



##### 2.compile linux -- linux root catelogue #####

# 编译linux内核
export ARCH=arm  						# 指定核心类型
export CROSS_COMPILE=arm-linux-gnueabi- # 指定交叉编译前缀
make vexpress_defconfig					# 使用预配置文件
make zImage dtbs modules -j8			# 编译


# 拷贝生成的ZImag、dtbs 到单独的文件夹中
cp arch/arm/boot/zImage ../extra_folder/
cp arch/arm/boot/dts/*ca9.dtb ../extra_folder/


##### 3.make root filesystem -- busybox root catelogue #####

# 生成busybox运行指令
export ARCH=ARM
export CROSS_COMPILE=arm-linux-gnueabi-
make defconfig
make install -j8


# 创建文件系统目录
cd _install
mkdir -p dev etc lib proc sys mnt tmp var
mkdir -p etc/init.d
cd ..


# 添加/etc/配置文件
git clone https://github.com/mahadevvinay/Embedded_Linux_Files.git ../Embedded_Linux_Files
sudo cp ../Embedded_Linux_Files/fstab _install/etc/
sudo cp ../Embedded_Linux_Files/inittab _install/etc/
sudo cp ../Embedded_Linux_Files/rcS _install/etc/init.d/
sudo rm -rf ../Embedded_Linux_Files/


# 修改可执行权限
sudo chmod a+x _install/etc/init.d/rcS
sudo chmod 777 _install/etc/init.d/rcS


# 安装modules
cd ../linux-4.4.1/
make modules_install ARCH=arm INSTALL_MOD_PATH=../busybox-1.25.1/_install
cd ../busybox-1.25.1/


# 拷贝交叉编译工具链运行库
sudo cp -P /usr/arm-linux-gnueabi/lib/* _install/lib/


# 创建4个tty终端设备
# c代表字符设备，4是主设备号，1~2~3~4是次设备号
sudo mknod _install/dev/tty1 c 4 1
sudo mknod _install/dev/tty2 c 4 2
sudo mknod _install/dev/tty3 c 4 3
sudo mknod _install/dev/tty4 c 4 4


# 制作根文件系统镜像
dd if=/dev/zero of=a9rootfs.ext3 bs=1M count=32
mkfs.ext3 a9rootfs.ext3
sudo mkdir -p tmpfs
sudo mount -t ext3 a9rootfs.ext3 tmpfs/ -o loop
sudo cp -r _install/*  tmpfs/
sudo umount tmpfs

# 拷贝生成的文件系统到目标文件夹中
cp a9rootfs.ext3 ../extra_folder/



##### 4.open network support for qemu #####

# 安装必要的工具包
sudo apt-get install uml-utilities
sudo apt-get install bridge-utils

# 查看本地网络连接
ifconfig

# 建立桥接
sudo atom /etc/network/interfaces

auto br0
iface br0 inet dhcp
	bridge_ports inet_name

# 立即生效
sudo /etc/init.d/networking restart


##### 5.open tftp service #####

# 安装必要的工具包
sudo apt-get install tftp-hpa     	# 客户端软件
sudo apt-get install tftpd-hpa   	# 服务程序

# 建立tftp服务器工作目录
mkdir -p /path/to/tftpboot
chmod 777 /path/to/tftpboot			# 允许其它主机上传或者下载文件

# 修改tftpd-hpa配置文件
sudo atom /etc/default/tftpd-hpa
TFTP_DIRECTORY="/path/to/tftpboot"  # tftp服务器工作目录

# 开启tftp服务
service tftpd-hpa restart

# 测试tftp服务
touch /path/to/tftpboot/test
tftp inet_addr
> get test



##### 6.compile u-boot -- u-boot root catelogue #####

# 修改参数配置文件
sudo atom /include/configs/vexpress_common.h

#define CONFIG_BOOTCOMMAND \
        "run distro_bootcmd; " \
        "run bootflash; " \
        "setenv serverip 172.20.94.226; " \
        "tftp 0x60003000 uImage; " \
        "tftp 0x60500000 vexpress-v2p-ca9.dtb; " \
        "setenv bootargs 'init=/linuxrc root=/dev/mmcblk0 rw console=ttyAMA0'; " \
        "bootm 0x60003000 - 0x60500000; "

# 编译
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabi-
make vexpress_ca9x4_defconfig
make -j8

# 将zImage转换成uImage格式
cd tools
./mkimage -n 'Cortex-A9' -A arm -O linux -T kernel -C none -a 0x60003000 -e 0x60003000 -d /path/to/zImage /path/to/uImage



##### 7.run linux #####
# 通过uboot启动，在当前窗口运行命令行界面
qemu-system-arm \
	-M vexpress-a9 \
	-m 256M \
  	-kernel /path/to/u-boot \
  	-sd /path/to/a9rootfs.ext3 \
  	-nographic

# qemu直接启动，在新的终端窗口运行图形化界面
qemu-system-arm \
  	-M vexpress-a9 \
  	-m 256M \
  	-kernel /path/to/zImage \
  	-dtb /path/to/vexpress-v2p-ca9.dtb \
  	-sd /path/to/a9rootfs.ext3 \
  	-append "root=/dev/mmcblk0 rw" \
  	-serial stdio \
  	-smp 4

# qemu直接启动，在当前窗口运行命令行界面
qemu-system-arm \
  	-M vexpress-a9 \
  	-m 256M \
  	-kernel /path/to/zImage \
  	-dtb /path/to/vexpress-v2p-ca9.dtb \
  	-sd /path/to/a9rootfs.ext3 \
  	-append "root=/dev/mmcblk0 rw console=ttyAMA0" \
  	-nographic \
  	-smp 4

