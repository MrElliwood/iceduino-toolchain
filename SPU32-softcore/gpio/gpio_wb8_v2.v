module gpio_wb8(
        // Wishbone signals
        input I_wb_adr,
        input I_wb_clk,
        input[7:0] I_wb_dat,
        input I_wb_stb,
        input I_wb_we,
        output reg O_wb_ack,
        output reg[7:0] O_wb_dat,
        // reset signal
        input I_reset,
        // output for LEDS
        inout[7:0] GPIO_port
    );

    reg[7:0] direction = 0;
    reg[7:0] GPIOvalue = 0;
	
	// assign output statements
    assign GPIO_port[7] = direction[7] ? GPIOvalue[7] : 1'bZ;
    assign GPIO_port[6] = direction[6] ? GPIOvalue[6] : 1'bZ;
    assign GPIO_port[5] = direction[5] ? GPIOvalue[5] : 1'bZ;
    assign GPIO_port[4] = direction[4] ? GPIOvalue[4] : 1'bZ;
    assign GPIO_port[3] = direction[3] ? GPIOvalue[3] : 1'bZ;
    assign GPIO_port[2] = direction[2] ? GPIOvalue[2] : 1'bZ;
    assign GPIO_port[1] = direction[1] ? GPIOvalue[1] : 1'bZ;
    assign GPIO_port[0] = direction[0] ? GPIOvalue[0] : 1'bZ;
	
	
	wire[7:0] port_in;
	//assign input statements
	assign port_in[7] = direction[7] ? GPIOvalue[7] : GPIO_port[7];
    assign port_in[6] = direction[6] ? GPIOvalue[6] : GPIO_port[6];
    assign port_in[5] = direction[5] ? GPIOvalue[5] : GPIO_port[5];
    assign port_in[4] = direction[4] ? GPIOvalue[4] : GPIO_port[4];
    assign port_in[3] = direction[3] ? GPIOvalue[3] : GPIO_port[3];
    assign port_in[2] = direction[2] ? GPIOvalue[2] : GPIO_port[2];
    assign port_in[1] = direction[1] ? GPIOvalue[1] : GPIO_port[1];
    assign port_in[0] = direction[0] ? GPIOvalue[0] : GPIO_port[0];

    always @(posedge I_wb_clk) begin
	    O_wb_ack <= I_wb_stb;
        if(I_wb_stb) begin
            if(I_wb_we) begin //Write
                case(I_wb_adr)
                    0: begin //write to GPIO pins
                        GPIOvalue <= I_wb_dat;
                    end
                    1: begin //write to pin configuration
                        direction <= I_wb_dat;
                    end
                endcase
            end else begin
                case(I_wb_adr)
                    0: begin //read from GPIO pins
                        O_wb_dat <= port_in;
                    end
                    1: begin //read pin configuration
                        O_wb_dat <= direction;
                    end
                endcase
            end
        end


        if(I_reset) begin
            direction <= 0;
            GPIOvalue <= 0;
        end

    end

endmodule
