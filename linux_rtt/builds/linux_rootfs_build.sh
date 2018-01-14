##### 在busybox文件夹下运行 #####

##### 根文件系统 = busybox(包含基础的Linux命令)  + 运行库 + 几个字符设备

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

