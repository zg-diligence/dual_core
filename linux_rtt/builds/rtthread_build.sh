# 编译
cd bsp/qemu-vexpress-a9
scons

# 拷贝生成文件到目标文件夹
cp rtthread.elf ../../../extra_folder

