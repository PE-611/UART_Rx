module UART_Rx (input clk, Rx,                     
					 output reg [7:0] data, 
					 output reg i				//for generation and checking UART_clk
					 );
					 
parameter Fclk = 100 * 1000000;			// Input clk [Hz]
parameter Fuart = 9600;						// recomended 230400, 115200, 57600, 38400, 33600, 28800, 19200, 14400, 9600, 1200.   		 	
parameter divider	= (Fclk / (Fuart *2)) - 1;		
					 
initial data <= 8'b00000000;
initial i <= 1'b0;												
reg [15:0]	cnt;
initial cnt <= 16'd0;				

	always @(posedge clk) begin
		cnt <= cnt + 1'b1;
		if (cnt == divider) begin		   // generation UART_clk Hz.
		cnt <= cnt - divider;
		i <= ~i;									// UART clk
		end
	end
					
reg l;											// receive flag
initial l <= 1'b0;
reg [2:0] g;									// counter of the bits for recieve (8 bit)
					
	always @(posedge i) begin				// 
			
		if (Rx == 1'b0) begin				// detector of the UART start bit
			l <= 1'b1;							// set receive flag 
		end
						
		if (l == 1'b1) begin					// if and while the flag = 1, we write receive bits in bits in shift reg
			data <=  {data[7:0], Rx};
			g <= g + 1'b1;
		end
		
		if (g == 3'd7) begin				   // if number of the bits for recieve == 8, we ->
			l <= ~l;								// -> reset receive flag, ->
			g <= g - 3'd7;						// -> clear counter of the bits for recieve and ->
			
		end
	end
		
endmodule