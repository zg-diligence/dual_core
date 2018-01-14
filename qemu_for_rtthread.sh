##### 1.compile RT-Thread -- RT-Thread root catelogue #####

# 编译准备
sudo apt install -y scons
sudo apt install -y gcc-arm-none-eabi

# 编译
cd bsp/qemu-vexpress-a9
scons


#### 2.run RT-Thread #####

# 运行
qemu-system-arm -M vexpress-a9 -kernel /path/to/rtthread.elf -nographic

# 简单测试
list_thread
	
