#include <linux/module.h>
#include <linux/cpu.h>


static int __init unplug_init(void)
{
	int ret;
	
	ret = cpu_down(1);
	if (ret && (ret != -EBUSY)) {
		pr_err("Can't release cpu1: %d\n", ret);
		return -ENOMEM;
	}
	return 0;
}


static void __exit unplug_exit(void){}


module_init(unplug_init);
module_exit(unplug_exit);

MODULE_AUTHOR("Zhang Gang <zg_hit2015@163.com>");
MODULE_DESCRIPTION("CPU_UNPLUG");
MODULE_LICENSE("GPL");

