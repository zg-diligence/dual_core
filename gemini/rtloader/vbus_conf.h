#ifndef VBUS_CONFIG_H__
#define VBUS_CONFIG_H__

#define _RT_VBUS_RING_BASE (0x70000000 - 8 * 1024 * 1024) /* VBUS ring 基地址 */
#define _RT_VBUS_RING_SZ   (2 * 1024 * 1024)			  /* VBUS ring 大小*/

#define RT_VBUS_OUT_RING   ((struct rt_vbus_ring*)(_RT_VBUS_RING_BASE))
#define RT_VBUS_IN_RING    ((struct rt_vbus_ring*)(_RT_VBUS_RING_BASE + _RT_VBUS_RING_SZ))

#define RT_VBUS_GUEST_VIRQ   14	/* 发送中断 */
#define RT_VBUS_HOST_VIRQ    15	/* 接受中断 */

#define RT_VBUS_SHELL_DEV_NAME "vbser0"
#define RT_VBUS_RFS_DEV_NAME   "rfs"

#define RT_BASE_ADDR    0x6FC00000	/* RT-Thread 基地址 */
#define RT_MEM_SIZE     0x400000	/* RT-Thread 内存大小 */

/* Number of blocks in VBus. The total size of VBus is
 * RT_VMM_RB_BLK_NR * 64byte * 2. */
#define RT_VMM_RB_BLK_NR     (_RT_VBUS_RING_SZ / 64 - 1) 

#endif
