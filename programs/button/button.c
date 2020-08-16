/* 
Von 8 Bit Daten sind 5 Bit für die 5 Buttons bzw. 5 Leds
Wird ein Button gedrückt, leuchtet die jeweilige Led
*/

#define reg_leds (*(volatile uint8_t*)0xFFFFFFE2)  //Adresse Leds
#define reg_button (*(volatile uint8_t*)0xFFFFFFE0) //Adresse Buttons

void main() {
	uint8_t btn0 = reg_button;    
	while (1) { 
		 btn0 = reg_button; //Einlesen der Buttons Bit0=Buttton1, Bit1=Button2 , etc. 
		 reg_leds = btn0; //Ausgabe an Leds Bit0=Led1, Bit1=Led2, etc.
	} 
}
