
#include <register.h>
#include <map.h>

.text
.global __start
__start:
	
b reset
ldr pc, =_Undefined_instructions
ldr pc, =_Software_interrupt
ldr pc, =_Prefetch_Abort
ldr pc, =_Data_Abort
ldr pc, =_Useless
ldr pc, =_IRQ
ldr pc, =_FIQ

/*
**这里定义了异常向量表，当CPU异常时候就会跳转
**到这里执行，因此必须这么写，其中Useless也是
**必须的,它使得IRQ和FIQ的异常向量地址符合异常
**向量表.
**Note:ldr pc, _Undefined_instructions 不对
**这样的话，pc中放的是_Undefined_instructions
**第一个字节的值，显然不对.
*/

_Undefined_instructions:
	nop
_Software_interrupt:
	nop
_Prefetch_Abort:
	nop
_Data_Abort:
	nop
_Useless:
	nop
_IRQ:
	nop
_FIQ:
	nop

/*
**1、初始化应当遵循一定的顺序，如果要点亮LED这种外围设备，应该先初始化外围设备接口
**	 即256M(0x70000000-0x7fffffff)
**2、跳转到内存之前应该清空Dcache，并关闭，这样避免，cpu取数据时候从cache中取，因为
**	 此时Dchche还没有初始化，数据都不对
**3、如果需要操作内存，uart等设备，需要初始化时钟，因为他们分别工作在不同的时钟频率
**4、跳转到C语言函数，应该先设置好C语言环境，即堆栈
*/	
reset:
	bl set_svc
	bl set_peri_port
	bl disable_watchdog		@如果不关闭看门狗，后续的延时程序会导致不能喂狗，系统重启	
	bl invalidate_caches
	bl disable_mmu_caches
	bl init_stack
	bl init_clock
	bl mem_init
	bl main
	bl led_on
	nop

@set svc and disable interrupt	
set_svc:
	mrs r0, cpsr
	bic r0, r0, #0x1f
	orr r0, r0, #0xd3
	mov pc, lr

/*	
**You can access CP15 registers with MRC and MCR instructions:
**MCR{cond} P15,<Opcode_1>,<Rd>,<CRn>,<CRm>,<Opcode_2>
**MRC{cond} P15,<Opcode_1>,<Rd>,<CRn>,<CRm>,<Opcode_2>	
*/
invalidate_caches:
	mov r0, #0
	mcr p15, 0, r0, c7, c7, 0 @Invalidate Both Caches.
	mcr p15, 0, r0, c8, c7, 0 @Invalidate unified TLB unlocked entries,TLB is MMU cache 
	mov pc, lr
	
disable_mmu_caches:
	mrc p15, 0, r0, c1, c0, 0
	bic r0, r0, #0x0002		@Data cache disabled, reset value.
	bic r0, r0, #0x1000		@Instruction Cache disabled, reset value
	bic r0, r0, #0x0001 	@MMU disabled, reset value.
	mcr p15, 0, r0, c1, c0, 0	
	mov pc, lr

set_peri_port:
	ldr	r0, =0x70000000
	orr	r0, r0, #0x13
	mcr	p15,0,r0,c15,c2,4   @ 256M(0x70000000-0x7fffffff)
	mov pc, lr
	
#define pWTCON 0x7e004000
disable_watchdog:
		ldr r0, =pWTCON
		mov r1, #0x0
		str r1, [r0]
		mov pc, lr	
	
init_stack:
	ldr sp, =DDR_BASE+DDR_SIZE @Arm的栈是倒生长的
	mov pc, lr

/*
**步骤
**1、地板原理图搜索LED，找到对应的NLED1，核心板搜索NLED1，找到对应的GPIOM0
**2、s3c6410芯片手册，搜索GPIOM0
*/
led_on:
	ldr r0, =GPMCON
	ldr r1, =0x1111
	str r1, [r0]
		
	ldr r0, =GPMDAT
	ldr r1, [r0]
	bic r1, r1, #0x0 @active low, shine all
	str r1, [r0]
		
	mov pc, lr

/*
**1、The lowest three bits of CLK_SRC register control the source clocks of three groups. When the bit has 0, then the
**input clock is bypassed to the group. Otherwise, the PLL output will be applied to the group.CLK_SRC最低的三位决定时钟
**来源，为1时来源为PLL
**2、The operating frequency can be controlled by the internal clock divider, DIVARM, without changing PLL frequency.
**不需要改变PLL频率，只需要操作内部时钟分频器	DIVarm就可以得到需要的频率
**3、HCLK_GATE register controls the mask operation of HCLKX2 and HCLK.
**4、PCLK_GATE register controls the mask operation of PCLK.
**5、The frequency ratio between AHB clock and APB clock must be an even integer value
**6、Typical value setting for clock dividers
**7、Power-on reset sequence
**NOTE:这里没有使用uboot推荐的配置，使用samsung手册推荐的配置
*/	

init_clock:
	@PLL_LOCK使用默认值

	/*
	**配置分频参数，分频后的频率给AXI,AHB,APB总线使用,这里使用推荐配置
	**APLL MPLL DIVarm DIVhclk2 DIVhclk DIVpclk		
	**533  266  0/533  0/266    1/133   3/66
	*/	
	
	@这里配置为同步模式
	ldr r0, =OTHERS
	ldr r1, [r0]
	orr r1, r1, #0xc0
	str r1, [r0]

	@配置APLL
	ldr r0, =APLL_CON
	ldr r1, =APLL_VAL
	str r1, [r0]

	ldr r0, =CLK_DIV0
	ldr r1, = DIV0_VAL
	str r1, [r0]	@配置PLL频率，并使能PLL，这里使用推荐的配置

	@选择时钟源为PLL，为整个系统提供稳定时钟		
	ldr r0, =CLK_SRC	
	mov r1, #0x3
	str r1, [r0]

	mov pc, lr