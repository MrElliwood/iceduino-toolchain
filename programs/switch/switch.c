/*
Testprogramm für Switches:
Die beiden Switches werden in einer Schleife eingelesen.
Wenn Switch1/2 geschlossen ist, gehen die ersten/letzten 4 Leds an.
Wenn beide Switches geschlossen sind, gehen alle 8 Leds an.
*/

#include <stdint.h>
#include <stdbool.h>

#define reg_leds (*(volatile uint8_t*)0xFFFFFFE2)	
#define reg_switches (*(volatile uint8_t*)0xFFFFFFE1)


void main() {
	
    //1.Bit von reg_switches = Switch1
    //2.Bit von reg_switches = Switch2	
    uint8_t sw1 = reg_switches & 0x1;
    uint8_t sw2 = reg_switches>>1 & 0x1;
       
    while (1) { 

	sw1 = reg_switches & 0x1;
    	sw2 = reg_switches>>1 & 0x1;

	if(sw1 && sw2==0){
		reg_leds = 0x0F;

	}else if(sw2 && sw1==0){
		reg_leds = 0xF0;

	}else if(sw1 && sw2){
		reg_leds = 0xFF;
	}
	else {
		reg_leds = 0;
	}		

    } 
}	

