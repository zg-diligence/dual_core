cp builds/linux_kernel_build.sh linux-4.4.1/build.sh
cp builds/linux_rootfs_build.sh busybox-1.25.1/build.sh
cp builds/linux_uboot_build.sh u-boot-2017.11/build.sh
cp builds/rtthread_build.sh rt-thread-3.0.0/build.sh

cd linux-4.4.1/
./build.sh
cd ..

cd busybox-1.25.1/
./build.sh
cd ..

cd u-boot-2017.11/
./build.sh
cd ..

cd rt-thread-3.0.0/
./build.sh
cd ..

