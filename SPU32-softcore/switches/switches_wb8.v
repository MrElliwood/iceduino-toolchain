module switches_wb8(
        // Wishbone signals
        input I_wb_clk,      
        input I_wb_stb,
		input I_wb_we,
        output reg O_wb_ack,
        output reg[7:0] O_wb_dat,      
        // input for button
        input[1:0] I_switches

    );
		
    always @(posedge I_wb_clk) begin
        if(I_wb_stb) begin
		if(!I_wb_we) begin
			O_wb_dat <= {6'b0,I_switches}; //switch on=1	
			//O_wb_dat <= {6'b0,~I_switches}; //switch on=0			
		end			
        end		
        O_wb_ack <= I_wb_stb; 
	end


endmodule
