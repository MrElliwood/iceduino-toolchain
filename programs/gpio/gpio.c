/*
Testprogramm für GPIO:
Es werden gpio0 und gpio1 als Output konfiguriert. In der Schleife werden die Buttons eingelesen und an die Leds und Gpio0 ausgegeben. Gpio1 bekommt das Eingelesene invertiert.
*/
#include <stdint.h>
#include <stdbool.h>

#define reg_leds (*(volatile uint8_t*)0xFFFFFFE2)    
#define reg_button (*(volatile uint8_t*)0xFFFFFFE0)
#define reg_gpio0_dir (*(volatile uint8_t*)0xFFFFFE01)
#define reg_gpio0_value (*(volatile uint8_t*)0xFFFFFE00)
#define reg_gpio1_dir (*(volatile uint8_t*)0xFFFFFE03)
#define reg_gpio1_value (*(volatile uint8_t*)0xFFFFFE02)


void main() {   
 
    uint8_t btn0 = reg_button;    
    reg_gpio0_dir = (uint8_t)0b11111111;
    reg_gpio1_dir = (uint8_t)0b11111111;
       
    while (1) { 
        btn0 = reg_button; 
        reg_leds = btn0;
        reg_gpio0_value = btn0;
        reg_gpio1_value = ~btn0;
    } 
} 
