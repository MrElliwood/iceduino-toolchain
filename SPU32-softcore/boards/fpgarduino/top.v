//`default_nettype none

//`include "./boards/hx8k-breakout/config-local.vh"

`include "./cpu/cpu.v"
`include "./leds/leds_wb8.v"
`include "./uart/uart_wb8.v"
`include "./spi/spi_wb8.v"
`include "./timer/timer_wb8.v"
`include "./rom/rom_wb8.v"
`include "./ram/bram_wb8.v"
`include "./ram/sram512kx8_wb8_vga.v"
`include "./button/button_wb8.v"
`include "./gpio/gpio_wb8.v"
`include "./switches/switches_wb8.v"

module top(
		
		//CLK 12MHZ	
        input clk_12mhz,
		
        //UART
        input uart_rx, uart_rt,
        output uart_tx,
		
        //SPI
        input spi_miso,
        output spi_clk, spi_mosi, spi_ss,

        //GPIO Port 0
        inout gpio0_pin0, gpio0_pin1, gpio0_pin2, gpio0_pin3, gpio0_pin4, gpio0_pin5, gpio0_pin6, gpio0_pin7,

        //GPIO Port 1
        inout gpio1_pin0, gpio1_pin1, gpio1_pin2, gpio1_pin3, gpio1_pin4, gpio1_pin5, gpio1_pin6, gpio1_pin7,

        //Buttons
        input btn0,btn1,btn2,btn3,btn4,

        //Switches
        input sw0, sw1,
		
        //LEDs
        output led0, led1, led2, led3, led4, led5, led6, led7,

        //Level Shifter
	output  oe0, oe1,
		
        // reset button
        //input reset_button,

        /*`ifdef EXTENSION_PRESENT
            // SRAM on extension board
       	    output sram_oe, sram_ce, sram_we,
            output sram_a0, sram_a1, sram_a2, sram_a3, sram_a4, sram_a5, sram_a6, sram_a7, sram_a8, sram_a9, sram_a10, sram_a11, sram_a12, sram_a13, sram_a14, sram_a15, sram_a16, sram_a17, sram_a18,
	        inout sram_d0, sram_d1, sram_d2, sram_d3, sram_d4, sram_d5, sram_d6, sram_d7
        `endif*/

    );

    //Enable Level Shifter for Arduino compatible Headers
    assign oe0 = 1'b1;
    assign oe1 = 1'b1;

	
    //wire clk;
    //assign clk = clk_12mhz;
    //localparam CLOCKFREQ = 12000000;

    //wire clk;
    //assign clk = clk_50mhz;
    //localparam CLOCKFREQ = 50000000;

	
    wire clk, clk_pll, pll_locked;
    // Instantiate PLL, 25.125 MHz
    SB_PLL40_CORE #(							
        .FEEDBACK_PATH("SIMPLE"),				
        .DIVR(4'b0000),
        .DIVF(7'b1000010),
        .DIVQ(3'b101),
        .FILTER_RANGE(3'b001)
    ) mypll (								
        .LOCK(pll_locked),					
        .RESETB(1'b1),						
        .BYPASS(1'b0),						
        .REFERENCECLK(clk_12mhz),				
        .PLLOUTCORE(clk)				
    );
    localparam CLOCKFREQ = 25125000;



    reg reset = 1;
    reg[10:0] resetcnt = 1;

    wire cpu_cyc, cpu_stb, cpu_we;
    wire[7:0] cpu_dat;
    wire[31:0] cpu_adr;

    reg[7:0] arbiter_dat_o;
    reg arbiter_ack_o;
    wire ram_stall;

    spu32_cpu #(
        .VECTOR_RESET(32'hFFFFF000)
    ) cpu_inst(
        .CLK_I(clk),
	    .ACK_I(arbiter_ack_o),
        .STALL_I(ram_stall),
	    .DAT_I(arbiter_dat_o),
	    .RST_I(reset),
        .INTERRUPT_I(timer_interrupt),
	    .ADR_O(cpu_adr),
	    .DAT_O(cpu_dat),
	    .CYC_O(cpu_cyc),
	    .STB_O(cpu_stb),
	    .WE_O(cpu_we)
    );
	
	
	
	//ROM
    wire rom_ack;
    reg rom_stb;
    wire[7:0] rom_dat;

    rom_wb8 #(
        .ROMINITFILE("./software/asm/switch.dat")
    ) rom_inst (
	    .I_wb_clk(clk),
	    .I_wb_stb(rom_stb),
	    .I_wb_adr(cpu_adr[8:0]),
	    .O_wb_dat(rom_dat),
	    .O_wb_ack(rom_ack)
    );

	//GPIO Port 0
    reg gpio0_stb = 0;
    wire[7:0] gpio0_dat;
    wire gpio0_ack;
    wire[7:0] gpio0_port;
	
	assign gpio0_port = {gpio0_pin0, gpio0_pin1, gpio0_pin2, gpio0_pin3, gpio0_pin4, gpio0_pin5, gpio0_pin6, gpio0_pin7};

    gpio_wb8 gpio0_inst(
        .I_wb_clk(clk),
        .I_wb_adr(cpu_adr[0]),
        .I_wb_dat(cpu_dat),
        .I_wb_stb(gpio0_stb),
        .I_wb_we(cpu_we),
        .I_reset(reset),
        .O_wb_dat(gpio0_dat),
        .O_wb_ack(gpio0_ack),
        .GPIO_port(gpio0_port)
    );

	//GPIO Port 1
    reg gpio1_stb = 0;
    wire[7:0] gpio1_dat;
    wire gpio1_ack;
    wire[7:0] gpio1_port;
	
	assign gpio1_port = {gpio1_pin0, gpio1_pin1, gpio1_pin2, gpio1_pin3, gpio1_pin4, gpio1_pin5, gpio1_pin6, gpio1_pin7};
	
    gpio_wb8 gpio1_inst(
        .I_wb_clk(clk),
        .I_wb_adr(cpu_adr[0]),
        .I_wb_dat(cpu_dat),
        .I_wb_stb(gpio1_stb),
        .I_wb_we(cpu_we),
        .I_reset(reset),
        .O_wb_dat(gpio1_dat),
        .O_wb_ack(gpio1_ack),
        .GPIO_port(gpio1_port)
    );

//Button
    reg button0_stb;
    wire[7:0] button0_dat;
    wire[4:0] btn;
    wire button0_ack;

    button_wb8 button0_inst(
        .I_wb_clk(clk),       
        .I_wb_stb(button0_stb),
        .I_wb_we(cpu_we),    
        .O_wb_dat(button0_dat),
        .O_wb_ack(button0_ack),
        .I_button(btn)
    );
    assign {btn0,btn1,btn2,btn3,btn4} = btn;


	//Switches
    reg switch_stb;
    wire[7:0] switch_dat;
    wire[1:0] sw;
    wire switch_ack;

    switches_wb8 switches_inst(
        .I_wb_clk(clk),       
        .I_wb_stb(switch_stb),
        .I_wb_we(cpu_we),    
        .O_wb_dat(switch_dat),
        .O_wb_ack(switch_ack),
        .I_switches(sw)
    );
    assign {sw0,sw1} = sw;

	
	//LEDs
    reg leds_stb;
    wire[7:0] leds_value, leds_dat;
    wire leds_ack;

    leds_wb8 leds_inst(
        .I_wb_clk(clk),
        .I_wb_dat(cpu_dat),
        .I_wb_stb(leds_stb),
        .I_wb_we(cpu_we),
        .I_reset(reset),
        .O_wb_dat(leds_dat),
        .O_wb_ack(leds_ack),
        .O_leds(leds_value)
    );
    assign {led0, led1, led2, led3, led4, led5, led6, led7} = leds_value;
	
	
	//UART
    reg uart_stb = 0;
    wire uart_ack;
    wire[7:0] uart_dat;

    uart_wb8 #(
        .CLOCKFREQ(CLOCKFREQ)
    ) uart_inst(
        .I_wb_clk(clk),
        .I_wb_adr(cpu_adr[1:0]),
        .I_wb_dat(cpu_dat),
        .I_wb_stb(uart_stb),
        .I_wb_we(cpu_we),
        .O_wb_dat(uart_dat),
        .O_wb_ack(uart_ack),
        .O_tx(uart_tx),
        .I_rx(uart_rx)
    );


	//SPI
	reg spi_stb = 0;
    wire[7:0] spi_dat;
    wire spi_ack;

    spi_wb8 spi0_inst(
        .I_wb_clk(clk),
        .I_wb_adr(cpu_adr[1:0]),
        .I_wb_dat(cpu_dat),
        .I_wb_stb(spi_stb),
        .I_wb_we(cpu_we),
        .O_wb_dat(spi_dat),
        .O_wb_ack(spi_ack),
        .I_spi_miso(spi_miso),
        .O_spi_mosi(spi_mosi),
        .O_spi_clk(spi_clk),
        .O_spi_cs(spi_ss)
    );


	//TIMER
    reg timer_stb = 0;
    wire[7:0] timer_dat;
    wire timer_ack;
    wire timer_interrupt;

    timer_wb8 #(
        .CLOCKFREQ(CLOCKFREQ)
    )timer_inst(
        .I_wb_clk(clk),
        .I_wb_adr(cpu_adr[2:0]),
        .I_wb_dat(cpu_dat),
        .I_wb_stb(timer_stb),
        .I_wb_we(cpu_we),
        .O_wb_dat(timer_dat),
        .O_wb_ack(timer_ack),
        .O_interrupt(timer_interrupt)
    );


	//RAM
    wire[7:0] ram_dat;
    reg ram_stb;
    wire ram_ack;
   /* `ifdef EXTENSION_PRESENT
        // if the extension board is present, use the external SRAM chip
        wire[7:0] sram_dat_to_chip;
        wire[7:0] sram_dat_from_chip;
        wire sram_output_enable;
        wire[18:0] sram_chip_adr;
        assign {sram_a0, sram_a1, sram_a2, sram_a3, sram_a4, sram_a5, sram_a6, sram_a7, sram_a8, sram_a9, sram_a10, sram_a11, sram_a12, sram_a13, sram_a14, sram_a15, sram_a16, sram_a17, sram_a18} = sram_chip_adr;
        wire[7:0] sram_chip_dat = {sram_d7, sram_d6, sram_d5, sram_d4, sram_d3, sram_d2, sram_d1, sram_d0};

        sram512kx8_wb8_vga sram_inst(
            // wiring to wishbone bus
            .I_wb_clk(clk),
            .I_wb_adr(cpu_adr[18:0]),
            .I_wb_dat(cpu_dat),
            .I_wb_stb(ram_stb),
            .I_wb_we(cpu_we),
            .O_wb_dat(ram_dat),
            .O_wb_ack(ram_ack),
            .O_wb_stall(ram_stall),
            // VGA read port
            .I_vga_req(vga_ram_req),
            .I_vga_adr(vga_ram_adr),
            // wiring to SRAM chip
            .O_data(sram_dat_to_chip),
            .I_data(sram_dat_from_chip),
		    .O_address(sram_chip_adr),
            .O_ce(sram_ce),
            .O_oe(sram_oe),
            .O_we(sram_we),
            // output enable
            .O_output_enable(sram_output_enable)
        );

        // instantiate IO blocks for tristate data lines
        genvar i;
        for(i = 0; i < 8; i = i + 1) begin
            SB_IO #(.PIN_TYPE(6'b 1010_01), .PULLUP(1'b 0)) io_block_instance (
                .PACKAGE_PIN(sram_chip_dat[i]),
                .OUTPUT_ENABLE(sram_output_enable),
                .D_OUT_0(sram_dat_to_chip[i]),
                .D_IN_0(sram_dat_from_chip[i])
            );            
        end

    `else*/
        // without the extension board, generate 8KB of RAM out of BRAM ressources
        bram_wb8 #(
            .ADDRBITS(13)
        ) bram_inst(
            .I_wb_clk(clk),
            .I_wb_adr(cpu_adr[12:0]),
            .I_wb_dat(cpu_dat),
            .I_wb_stb(ram_stb),
            .I_wb_we(cpu_we),
            .O_wb_dat(ram_dat),
            .O_wb_ack(ram_ack)
        );
        assign ram_stall = 0;
    `endif




    // The iCE40 BRAMs always return zero for a while after device program and reset:
    // https://github.com/cliffordwolf/icestorm/issues/76
    // Assert reset for a while until things should have settled.
    always @(posedge clk) begin
      if(resetcnt != 0) begin
        reset <= 1;
        resetcnt <= resetcnt + 1;
      end else reset <= 0;

      // use UART rts (active low) for reset
    //  if(!uart_rts || !reset_button) begin
     //   resetcnt <= 1;
     // end
    end

    // bus arbiter
    always @(*) begin
		
		rom_stb = 0;
		uart_stb = 0;
		spi_stb = 0;
		timer_stb = 0;
		leds_stb = 0; 
        ram_stb = 0;
		gpio0_stb = 0;
		gpio1_stb = 0;
		switch_stb = 0;
        button0_stb = 0;

        casez(cpu_adr[31:0])


			//ROM
            {20'hFFFFF, 1'b0, {11{1'b?}}}: begin // 0xFFFFF000 - 0xFFFFF7FF: boot ROM
                arbiter_dat_o = rom_dat;
                arbiter_ack_o = rom_ack;
                rom_stb = cpu_stb;
            end

			//UART
            {32'hFFFFF8??}: begin // 0xFFFFF8xx: UART
                arbiter_dat_o = uart_dat;
                arbiter_ack_o = uart_ack;
                uart_stb = cpu_stb;
            end
			
			//SPI
            {32'hFFFFF9??}: begin // 0xFFFFF9xx: SPI port
                arbiter_dat_o = spi_dat;
                arbiter_ack_o = spi_ack;
                spi_stb = cpu_stb;
            end

			//TIMER
            {32'hFFFFFD??}: begin // 0xFFFFFDxx: Timer
                arbiter_dat_o = timer_dat;
                arbiter_ack_o = timer_ack;
                timer_stb = cpu_stb;
            end

			//GPIO Port 0
            {28'hFFFFFE0,3'b0,1'b?}: begin // 0xFFFFFE00 - 0xFFFFFE01: GPIO Port 0
                arbiter_dat_o = gpio0_dat;
                arbiter_ack_o = gpio0_ack;
                gpio0_stb = cpu_stb;
            end

			//GPIO Port 1
            {28'hFFFFFE0,2'b0,1'b1,1'b?}: begin // 0xFFFFFE02 - 0xFFFFFE03: GPIO Port 1
                arbiter_dat_o = gpio1_dat;
                arbiter_ack_o = gpio1_ack;
                gpio1_stb = cpu_stb;
            end

            {32'hFFFFFFE0}: begin // 0xFFFFFFE0 Buttons
				arbiter_dat_o = button0_dat;
				arbiter_ack_o = button0_ack;
				button0_stb = cpu_stb;                      
            end
			
			{32'hFFFFFFE1}: begin // 0xFFFFFFE1 Switches
				arbiter_dat_o = switch_dat;
				arbiter_ack_o = switch_ack;
				switch_stb = cpu_stb;                      
			end

			//LEDs
            {32'hFFFFFFE2}: begin // 0xFFFFFFE2 LEDs
                arbiter_dat_o = leds_dat;
                arbiter_ack_o = leds_ack;
                leds_stb = cpu_stb;                      
            end
			
			
			/*
            {32'hFFFFFE??}: begin // 0xFFFFFExx: predictable random number generator
                arbiter_dat_o = prng_dat;
                arbiter_ack_o = prng_ack;
                prng_stb = cpu_stb;
            end*/
			
			// reserved:
            // 0xFFFFFAxx
            // 0xFFFFFBxx
            
           /* {32'hFFFFFC??}: begin // 0xFFFFFCxx: IR receiver
                arbiter_dat_o = irdecoder_dat;
                arbiter_ack_o = irdecoder_ack;
                irdecoder_stb = cpu_stb;
            end*/
			
			/*{32'hFFFFFF0?}: begin // 0xFFFFFF0x: audio
                arbiter_dat_o = audio_dat;
                arbiter_ack_o = audio_ack;
                audio_stb = cpu_stb;
            end*/

            // reserved:
            // 0xFFFFFF1x to 0xFFFFFFEx
			
			/*`ifdef EXTENSION_PRESENT
			{16'hFFFF, 3'b000, {13{1'b?}}}: begin //0xFFFF0000 - 0xFFFF1FFF: VGA
                    arbiter_dat_o = vga_dat;
                    arbiter_ack_o = vga_ack;
                    vga_stb = cpu_stb;
                end
            `endif*/
			
			//RAM			
            default: begin
                arbiter_dat_o = ram_dat;
                arbiter_ack_o = ram_ack;
                ram_stb = cpu_stb;
            end

        endcase

    end


endmodule
