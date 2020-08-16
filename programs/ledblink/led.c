
#include <stdint.h>
#include <stdbool.h>
#define reg_leds (*(volatile uint8_t*)0xFFFFFFE2)

void main() {
 
    uint32_t led = 0;
       
    while (1) {    
	//32 Bit werden hochgezählt, Bit 17-21 werden an den Leds angezeigt
    	reg_leds = (led >> 16) & 0xFF; 
		led = led  + 1;
    } 
}
