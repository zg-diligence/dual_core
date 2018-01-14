qemu-system-arm \
  -M vexpress-a9 \
  -m 512M \
  -dtb vexpress-v2p-ca9.dtb \
  -kernel zImage \
  -append "root=/dev/mmcblk0 rw console=ttyAMA0" \
  -sd a9rootfs.ext3 \
  -nographic \
  -smp 4

