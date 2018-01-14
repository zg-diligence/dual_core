##### 在项目根目录下执行 #####

mkdir -p packages

cd packages
wget https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.4.1.tar.xz
wget http://www.busybox.net/downloads/busybox-1.25.1.tar.bz2
wget https://github.com/RT-Thread/rt-thread/archive/v3.0.0.tar.gz
wget https://github.com/u-boot/u-boot/archive/v2017.11.tar.gz
mv v3.0.0.tar.gz rt-thread-3.0.0.tar.gz
mv v2017.11.tar.gz u-boot-2017.11.tar.gz
cd ..

tar -xvf packages/linux-4.4.1.tar.xz
tar -jxvf packages/busybox-1.25.1.tar.bz2
tar -xzvf packages/rt-thread-3.0.0.tar.gz
tar -xzvf packages/u-boot-2017.11.tar.gz

sudo apt-get install -y gcc-arm-none-eabi gcc-arm-linux-gnueabi
sudo apt-get install -y qemu scons libncurses5-dev zip bc texinfo

cp vexpress_common.h u-boot-2017.11/include/configs/vexpress_common.h

