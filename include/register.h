

#ifndef __REGISTER_H__
#define __REGISTER_H__

//clock
#define APLL_LOCK (0x7E00F000)	@Control PLL locking period for APLL,涉及到频率的问题，应该使得频率稳定才可以使用
#define MPLL_LOCK (0x7E00F004)
#define CLK_SRC (0x7E00F01C)	@Select clock source		
#define CLK_DIV0 (0x7E00F020)	@Set clock divider ratio
#define APLL_CON (0x7E00F00C)	@Control PLL output frequency for APLL
#define MPLL_CON (0x7E00F010)
#define HCLK_GATE (0x7E00F030)	@Control HCLK clock gating
#define PCLK_GATE (0x7E00F034)
#define OTHERS (0x7E00F900)	@Others control register
#define	APLL_VAL (1<<31|3<<8|266<<16|1<<0) @output 533mhz
#define	MPLL_VAL (2<<31|266<<16|3<<8|1<<0)	@output	266mhz
#define DIV0_VAL (0<<0|0<<4|1<<8|1<<9|3<<12)

//LED
#define GPMCON	(0x7F008820)
#define GPMDAT	(0x7F008824)






















#endif