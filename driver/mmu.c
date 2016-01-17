
#include <map.h>

#define MMU_FULL_ACCESS	(0b11 << 10)
#define MMU_DOMAIN_0	(0b0 << 5)
#define MMU_SPECIAL		(0b1 << 4)
#define MMU_CACHEABLE	(0b1 << 3)
#define MMU_BUFFERABLE	(0b1 << 2)
#define MMU_SECTION		(0b10)

#define MMU_SECDESC		(MMU_FULL_ACCESS | MMU_DOMAIN_0 | MMU_SPECIAL | MMU_SECTION)
#define MMU_SECDESC_CB	(MMU_FULL_ACCESS | MMU_DOMAIN_0 | MMU_SPECIAL | MMU_CACHEABLE | MMU_BUFFERABLE | MMU_SECTION)

static void create_pageTable()
{
	unsigned int vaddr = 0xa0000000;
	unsigned int paddr = 0x7f000000;
	unsigned int TTB_INDEX = vaddr >> 20;
	
	*((unsigned int*)(TTB_BASE + TTB_INDEX)) = (paddr & 0xfff00000) | MMU_SECDESC;

	vaddr = 0x50000000;
    paddr = 0x50000000;
	
	TTB_INDEX = vaddr >> 20;
    while (vaddr < 0x54000000)
    {
        *((unsigned int*)(TTB_BASE + TTB_INDEX)) = (paddr & 0xFFF00000) | MMU_SECDESC_CB;
        vaddr += 0x100000;
        paddr += 0x100000;
    }
}
 
void mmu_init()
{
	create_pageTable();
	
	__asm__(
		/*设置TTB*/
		"ldr r0, =0x50000000\n"
		"mcr p15, 0, r0, c2, c0, 0\n"
		/*所有domain不进行权限检查*/
		"mvn r0, #0x0\n"
		"mcr p15, 0, r0, c3, c0, 0\n"
		/*使能mmu*/
		"mrc p15, 0, r0, c1, c0, 0\n"
		"orr r0, r0, #0x0001\n"
		"mcr p15, 0, r0, c1, c0, 0\n"
		:
		:
	);
}

