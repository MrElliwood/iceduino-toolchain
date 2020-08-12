module gpio_wb8(
        // Wishbone signals
        input[1:0] I_wb_adr,
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
    assign GPIO_port[7] = direction[7] ? GPIOvalue[7] : 1'bZ;
    assign GPIO_port[6] = direction[6] ? GPIOvalue[6] : 1'bZ;
    assign GPIO_port[5] = direction[5] ? GPIOvalue[5] : 1'bZ;
    assign GPIO_port[4] = direction[4] ? GPIOvalue[4] : 1'bZ;
    assign GPIO_port[3] = direction[3] ? GPIOvalue[3] : 1'bZ;
    assign GPIO_port[2] = direction[2] ? GPIOvalue[2] : 1'bZ;
    assign GPIO_port[1] = direction[1] ? GPIOvalue[1] : 1'bZ;
    assign GPIO_port[0] = direction[0] ? GPIOvalue[0] : 1'bZ;

    always @(posedge I_wb_clk) begin
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
                        O_wb_dat <= GPIO_port;
                    end
                    1: begin //read pin configuration
                        O_wb_dat <= direction;
                    end
                endcase
            end
        end
        O_wb_ack <= I_wb_stb;

        if(I_reset) begin
            direction <= 0;
            GPIOvalue <= 0;
        end

    end

endmodule
