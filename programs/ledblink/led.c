#include <stdint.h>
#include <stdbool.h>

#define reg_leds (*(volatile uint8_t*)0xFFFFFFF0)

void main() {
 
    uint32_t led = 0;
       
    while (1) {    
    reg_leds = (led >> 16) & 0xFF;
    led = led  + 1;
    } 
}
