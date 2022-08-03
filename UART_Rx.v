///////////////////////////////////////////////////////////
// Name File : UART_Rx.v 											//
// Autor : Dyomkin Pavel Mikhailovich 							//
// Company : GSC RF TRINITI										//
// Description : UART Rx module								  	//
// Start design : 20.10.2020 										//
// Last revision : 28.10.2022 									//
///////////////////////////////////////////////////////////
module UART_Rx (input clk_Rx, Rx_in, 
					 output reg [7:0] data_out, 
					 output reg UART_clk,	//for generation and checking UART_clk
					 output reg wr,				// Readiness byte to write on memory
					 output reg [7:0] wr_addr,
					 output reg re
									 

					 );
					 
parameter Fclk = 100 * 1000000;			
parameter Fuart = 115200;								 	
parameter divider	= (Fclk / ((Fuart *2) - 1)); 		

initial wr <= 1'b1;
initial wr_addr <= 8'd113;          
initial re <= 1'b1;
					 
initial data_out <= 8'b00000000;
initial UART_clk <= 1'b0;	
										
reg [12:0]	cnt;
initial cnt <= 1'b0;	
reg [12:0] cnt_st;
initial cnt_st <= 1'b0;
reg [20:0] cnt_res;
initial cnt_res <= 1'b0;

reg reset;
initial reset <= 1'b0;

reg Rx_enable;
initial Rx_enable <= 1'b0;
reg receive_flg;										
initial receive_flg <= 1'b0;
reg [4:0] bit_cnt;									
initial bit_cnt = 1'b0;

always @(posedge clk_Rx) begin
	

	
	
	if (Rx_in == 1'b0 && Rx_enable == 1'b0 && bit_cnt == 1'b0 && receive_flg <= 1'b0) begin  	// условие для начала принятия байта
		Rx_enable <= 1'b1;																						  	// Флаг начала байта данных для приема
		wr <= 1'b0;
 	end
	
	if (Rx_enable == 1'b1) begin																					// Условие для начала счёта конца старт бита																				
		cnt_st = cnt_st + 1'b1;																						// Инкрементируем счетчик конца старт бита
		wr <= 1'b0;
	end
	
	if (cnt_st == (divider * 2)) begin																			// Условие конца старт бита
		receive_flg <= 1'b1;																							// Флаг разрешающий прием данных
		wr <= 1'b0;
	end
	
	if (receive_flg == 1'b1) begin																				// Условие для начала и продолжения генерации частоты УАРТ и начала отсчёта времени одного байта
		cnt <= cnt + 1'b1;																							// Инкрементируем счётчик для генерации частоты
		cnt_res <= cnt_res + 1'b1;																					// Инкрементируем счётчик времени одного байта
		wr <= 1'b0;
	end
	
	if (cnt == divider) begin																						// Условие для генерации частоты УАРТ																			
		cnt <= 1'b0;																									// Обнуляем счтчик генерации частоты
		UART_clk <= ~UART_clk;																						// Инвертируем состояние 
		wr <= 1'b0;
	end
	
	if (cnt_res == 20'd7000) begin																				// Условие окончания времени приёма байта
		cnt_res <= 1'b0;																								// Обнуляем счётчик времени байта
		reset <= 1'b1;																									// Устанавливаем флаг сброса системы в 1
		wr <= 1'b0;
	end
	
	if (reset == 1'b1) begin																						// Если флаг сброса равен 1
		reset <= 1'b0;																									// Обнуляем флаг сброса
		Rx_enable <= 1'b0;																							// Обнуляем флаг начала байта
		receive_flg <= 1'b0;																							// Обнуляем флаг разрешающий прием данных
		cnt <= 1'b0;																									// Обнуляем счётчик для генерации частоты УАРТ
		cnt_st <= 1'b0;																								// Обнуляем счётчик для отсчёта времени байта
		UART_clk <= 1'b0;																								// Обнуляем регистр выдающий частоту
		wr <= 1'b1;		
		wr_addr <= wr_addr - 1'b1;
	end

	
	if (wr_addr <= 1'b0) begin
		wr_addr <= 8'd113;
	end
	
	
	
		
end	
					

always @(posedge UART_clk) begin				 

			data_out <=  {data_out[7:0], Rx_in};

end
		
endmodule
