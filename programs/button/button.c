#include <stdint.h>
#include <stdbool.h>

#define reg_leds (*(volatile uint8_t*)0xFFFFFFF0)	
#define reg_button (*(volatile uint8_t*)0xFFFFFFE0)


void main() {
	
 
    uint8_t btn0 = reg_button;
       
    while (1) { 
		btn0 = reg_button; 
		reg_leds = btn0;		

    } 
}	
