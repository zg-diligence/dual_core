cd packages
wget https://buildroot.org/downloads/buildroot-2015.05.tar.bz2
wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.18.16.tar.xz
wget https://releases.linaro.org/archive/14.11/components/toolchain/binaries/arm-linux-gnueabi/gcc-linaro-4.9-2014.11-x86_64_arm-linux-gnueabi.tar.xz
cd ..

git clone https://git.coding.net/RT-Thread/rt-thread.git

sudo apt-get -y install lib32z1 astyle
sudo apt-get -y install gcc-arm-none-eabi
sudo apt-get -y install qemu-system-arm
sudo apt-get -y install scons libncurses5-dev zip bc texinfo

tar Jxvf packages/linux-3.18.16.tar.xz
tar jxvf packages/buildroot-2015.05.tar.bz2
tar Jxvf packages/gcc-linaro-4.9-2014.11-x86_64_arm-linux-gnueabi.tar.xz

mkdir -p buildroot-2015.05/dl
cp packages/dl/* buildroot-2015.05/dl

cd linux-3.18.16
patch -p1 < ../linux.patch
cd ..

