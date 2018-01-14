cp buildroot_config buildroot-2015.05/.config

cd buildroot-2015.05
make
cd ..

cd boot
./build.sh
scons -c
cd ..

cd vexpress
./build.sh
scons -c
cd ..

cd rtloader
./build.sh
cd ..

cd start_rtt
./build.sh
cd ..

cd unplug
./build.sh
cd ..

cd linux-apps
./build.sh
cd ..

cd buildroot-2015.05
make 
cd ..

cd buildroot-2015.05/output/images
cp * ../../../extra_folder/
cd -

