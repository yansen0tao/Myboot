
//#include <stdio.h>

extern void enable_led();
extern int light_up(unsigned int led_num);

int main(void)
{
	enable_led();
	light_up(2);
	
	return 0;
}
