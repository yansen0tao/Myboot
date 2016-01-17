
#include <register.h>
#include <map.h>

static unsigned int light_up_mask[] = {0b0111, 0b1011, 0b1101, 0b1110};

static void enable_led_phy()
{
	volatile unsigned int * gpmcon = (volatile unsigned int *)GPMCON;
	
	*gpmcon = 0x1111;
}

static int light_up_phy(unsigned int led_num)
{
	if (led_num > LED_MAX || led_num == 0)
		return -1;
	
	volatile unsigned int * gpmdat = (volatile unsigned int *)GPMDAT;

	*gpmdat = light_up_mask[led_num - 1];
}

static int light_off_phy(unsigned int led_num)
{
	if (led_num > LED_MAX || led_num == 0)
		return -1;
	
	volatile unsigned int * gpmdat = (volatile unsigned int *)GPMDAT;
	
	*gpmdat = ~light_up_mask[led_num - 1];
}

void enable_led()
{
	volatile unsigned int * gpmcon = (volatile unsigned int *)VGPMCON;
	
	*gpmcon = 0x1111;
}

int light_up(unsigned int led_num)
{
	if (led_num > LED_MAX || led_num == 0)
		return -1;
	
	volatile unsigned int * gpmdat = (volatile unsigned int *)VGPMDAT;

	*gpmdat = light_up_mask[led_num - 1];
}

int light_off(unsigned int led_num)
{
	if (led_num > LED_MAX || led_num == 0)
		return -1;
	
	volatile unsigned int * gpmdat = (volatile unsigned int *)VGPMDAT;
	
	*gpmdat = ~light_up_mask[led_num - 1];
}