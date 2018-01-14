#include <stdlib.h>
#include <rtthread.h>
#include <rtdevice.h>

#include <vbus.h>

#define BUFLEN 1024
static char buf[BUFLEN];

static void _vbus_on_tx_cmp(void *p)
{
    struct rt_completion *cmp = p;

    rt_completion_done(cmp);
}


/* 
 * 回写到端口设备/dev/rtvbus
 */
static rt_size_t _vbus_write_sync(rt_device_t dev, void *buf, rt_size_t len)
{
    rt_size_t sd;
    struct rt_completion cmp;
    struct rt_vbus_dev_liscfg liscfg;

    rt_completion_init(&cmp);
    liscfg.event = RT_VBUS_EVENT_ID_TX;
    liscfg.listener = _vbus_on_tx_cmp;
    liscfg.ctx = &cmp;

    rt_device_control(dev, VBUS_IOC_LISCFG, &liscfg);
    sd = rt_device_write(dev, 0, buf, len);

    rt_completion_wait(&cmp, RT_WAITING_FOREVER);

    return sd;
}


/* 
 * 字符串反序号,'\n'不交换
 */
static void _rev_str(char *buf, rt_size_t len)
{
    char tmp;
    rt_size_t i, mid;

    RT_ASSERT(buf);
    if (!len) return;

    mid = len / 2;
    for (i = 0; i < mid; i++){
        tmp = buf[i];
        buf[i] = buf[len - 1 - i];
        buf[len - 1 - i] = tmp;
    }
}

/* 
 * 从端口设备/dev/rtvbus读取字符串,反序后回写
 */
static void _test_write(void *devname)
{
    int i;
    rt_device_t dev;

	/* 寻找指定设备 */
    dev = rt_device_find(devname);
    if (!dev){
        rt_kprintf("could not find %s\n", devname);
        return;
    }

again:
	/* 从设备端口读取字符串存到buf */
    i = rt_device_open(dev, RT_DEVICE_OFLAG_RDWR);
    if (i){
        rt_kprintf("open dev err:%d\n", i);
        return;
    }

    for (i = 0; i < sizeof(buf) - 1;i++){
        int len;
        len = rt_device_read(dev, 0, buf + i, 1);
        if (len != 1 || buf[i] == '\n')
            break;
    }
    buf[i] = '\0';
    rt_kprintf("receive message: %s\n", buf);
    
    /* 字符串反序 */
    _rev_str(buf, i - 1);
    
    /* 字符串回写 */
    rt_kprintf("rewrite message: %s\n", buf);	/* Don't write the \0. */
    _vbus_write_sync(dev, buf, i - 1);
    
  	/* 关闭设备端口 */
    rt_device_close(dev);
    goto again;
}


int vser_echo_init(void)
{
    rt_thread_t tid;

    tid = rt_thread_create("vecho", _test_write, "vecho", 1024, 0, 20);
    RT_ASSERT(tid);
    return rt_thread_startup(tid);
}


#ifdef RT_USING_COMPONENTS_INIT
#include <components.h>
INIT_APP_EXPORT(vser_echo_init);
#endif
