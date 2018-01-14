#include <linux/module.h>
#include <linux/fs.h>
#include <linux/mm.h>
#include <linux/slab.h>
#include <linux/uaccess.h>
#include <linux/io.h>
#include <linux/cpu.h>
#include <linux/memblock.h>
#include <asm/cacheflush.h>
#include <vbus_api.h>
#include <vbus_layout.h>
#include "linux_driver.h"

#define BUFF_SZ	4 * 1024

/* wake up CPU#1, start up RT-Thread */
static int startup_rtt(unsigned long start_addr)
{
    extern int vexpress_cpun_start(u32 address, int cpu);
    vexpress_cpun_start(start_addr, 1);
    return 0;
}


/* load binary file, boot.bin rtthread.bin */
int loading_file(const char* filename, unsigned long base_addr, size_t mem_size)
{
	mm_segment_t oldfs = {0};
	ssize_t len;
	unsigned long file_sz;
	loff_t pos = 0;
	struct file *flp = NULL;
	unsigned long buf_ptr = base_addr;

	printk("start loading binary file:%s to %08lx....\n", filename, buf_ptr);

	/* open the binary file */
	flp = filp_open(filename, O_RDONLY, S_IRWXU);
	if (IS_ERR(flp)) {
		printk("rtloader: failed to open the binary file. return 0x%p\n", flp);
		return -1;
	}

	/* get size of the binary file */
	file_sz = vfs_llseek(flp, 0, SEEK_END);
	if (file_sz > mem_size) {
		printk("rtloader: the binary file is too big. size of the memory:"
			   "0x%08x, size of the binary file: %ld (0x%08lx)\n", mem_size, file_sz, file_sz);
		filp_close(flp, NULL);
		return -1;
	}
	printk("rtloader: size of the binary file: %ld\n", file_sz);
	vfs_llseek(flp, 0, SEEK_SET);

	/* read the binary file to memory */
	oldfs = get_fs();
	set_fs(get_ds());
	while (file_sz > 0) {
		len = vfs_read(flp, (void __user __force*)buf_ptr, BUFF_SZ, &pos);
		if (len < 0) {
			pr_err("read %08lx error: %d\n", buf_ptr, len);
			set_fs(oldfs);
			filp_close(flp, NULL);
			return -1;
		}
		file_sz -= len;
		buf_ptr += len;
	}
	set_fs(oldfs);
	printk("finish loading binary file\n\n");

	/* flush the memory */
	flush_cache_vmap(base_addr, mem_size);
	return 0;
}

static void __iomem *out_ring;

/*
 * load RTthread、cpu_down、restart rtt、load vbus driver
 */
static int __init rtloader_init(void)
{
	int ret;
	unsigned long va;

	/* load boot.bin */
	va = __phys_to_virt(0x6FB00000);
	ret = loading_file("/root/boot.bin", (unsigned long)va, 128 * 1024);

	/* load rtthread.bin */
	va = __phys_to_virt(0x6FC00000);
	ret = loading_file("/root/rtthread.bin", (unsigned long)va, RT_MEM_SIZE);

	pr_info("address mapping:%08lx -> %08x, size:%08x\n", va, RT_BASE_ADDR, RT_MEM_SIZE);

	if (ret == 0) {
		/* unplug CPU#1 */
		ret = cpu_down(1);
		if (ret && (ret != -EBUSY)) {
			pr_err("can't release cpu1: %d\n", ret);
			return -ENOMEM;
		}

		/* start up rtthread */
		ret = startup_rtt(0x6FB00000);

		/* load vbus driver */
		pr_info("start loading the vbus driver\n");
		out_ring = (void*)__phys_to_virt(_RT_VBUS_RING_BASE);
		ret = driver_load(out_ring, out_ring + _RT_VBUS_RING_SZ);
		pr_info("finish loading the vbus driver\n\n");
	}

	return 0;
}

static void __exit rtloader_exit(void)
{
    driver_unload();
}

module_init(rtloader_init);
module_exit(rtloader_exit);

MODULE_AUTHOR("Zhang Gang <zg_hit2015@163.com>");
MODULE_DESCRIPTION("RTLOADER");
MODULE_LICENSE("GPL");
