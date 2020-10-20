module UART_Rx (input clk, Rx,                     
					 output  [0:7] data, 
					 output reg i				//for generation and checking UART_clk
					 );

initial i <= 1'b0;												
reg [14:0]	cnt;
initial cnt <= 15'd0;				

	always @(posedge clk) begin
		cnt <= cnt + 1'b1;
		if (cnt == 15'd5207) begin		   // generation UART_clk = 9600 Hz.
		cnt <= cnt - 15'd5207;
		i <= ~i;
		end
	end

	receive (.shift(data), .Rx_in(Rx), .UART_clk(i));
	
endmodule					
					
////////////////////////////////////////////////////////////////

module receive (input UART_clk,
					 input Rx_in,
					 output reg [7:0] shift,
					 output reg [2:0] g
					);
					

reg [2:0] z;									// counter of the data bits in shift reg
initial z <= 1'd0;
reg l;											// receive flag
initial l <= 1'b0;
initial g <= 2'd0;  							// counter of the bits for recieve (8 bit)
initial shift <= 7'b00000000;				// data shift reg
					
	always @(posedge UART_clk) begin		// 
			
		if (Rx_in == 1'b0) begin			// detector of the UART start bit
			l <= 1'b1;							// set receive flag 
		end
						
		if (l == 1'b1) begin					// if and while the flag = 1, we write receive bits in bits in shift reg
			shift[z] <= Rx_in;
			z <= z + 1'b1;
			g <= g + 1'b1;
		end
		
		if (g == 3'd7) begin				   // if number of the bits for recieve == 8, we ->
			l <= ~l;								// -> reset receive flag, ->
			g <= g - 3'd7;						// -> clear counter of the bits for recieve and ->
			z <= z - 3'd7;						// -> clear counter of the data bits in shift reg.
			
		end

	end



		
endmodule

////////////////////////////////////////////////////////////////