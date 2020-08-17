/* 
Von 8 Bit Daten sind 5 Bit für die 5 Buttons bzw. 5 Leds
Wird ein Button gedrückt, leuchtet die jeweilige Led
#define reg_leds (*(volatile uint8_t*)0xFFFFFFE2)	
#define reg_button (*(volatile uint8_t*)0xFFFFFFE0)
#define reg_gpio0_dir (*(volatile uint8_t*)0xFFFFFE01)
#define reg_gpio0_value (*(volatile uint8_t*)0xFFFFFE00)
#define reg_gpio1_dir (*(volatile uint8_t*)0xFFFFFE03)
#define reg_gpio1_value (*(volatile uint8_t*)0xFFFFFE02)


void main() {
	
	reg_gpio0_dir = (uint8_t)0b11111111;
	reg_gpio1_dir = (uint8_t)0b11111111;
       
    while (1) { 
		btn0 = reg_button;
		reg_leds = btn0;

		reg_gpio0_value = btn0;
		reg_gpio1_value = ~btn0;
    } 
}	
