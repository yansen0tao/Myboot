
//#include <stdio.h>

extern void enable_led();
extern int light_up(unsigned int led_num);

extern void mmu_init();

int main(void)
{
	mmu_init();
	
	enable_led();
	light_up(2);
	
	return 0;
}
