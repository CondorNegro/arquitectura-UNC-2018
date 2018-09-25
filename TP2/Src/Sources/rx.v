`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2017 08:21:19 PM
// Design Name: 
// Module Name: receiver
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module rx
    ( 
    	//input
		clk,
		reset,
		rx,
		tick,

		//output
		rx_done_tick,
		data_out
	); 

	parameter LEN_DATA = 8;
	parameter LEN_DATA_COUNTER = $clog2(LEN_DATA); 
	parameter NUM_TICKS = 16;
	parameter LEN_NUM_TICKS_COUNTER = $clog2(NUM_TICKS); 

	input clk;
	input reset;
	input rx;
	input tick;
	output reg rx_done_tick;
	output [LEN_DATA-1:0] data_out;
	
	localparam	[3:0] IDLE 	= 4'b 1000;
	localparam	[3:0] START	= 4'b 0100;
	localparam	[3:0] DATA	= 4'b 0010;
	localparam	[3:0] STOP 	= 4'b 0001;

	reg [3:0] state, state_next;
	reg [LEN_NUM_TICKS_COUNTER - 1:0] acc_tick, acc_tick_next;
	reg [LEN_DATA_COUNTER - 1:0] num_bits, num_bits_next;
	reg [LEN_DATA - 1:0] buffer, buffer_next;

	assign data_out = buffer; 

	always @(posedge clk, posedge reset) 
	begin 
		if (reset)
		begin 
			state <= IDLE; 
			acc_tick <= 0; 
			num_bits <= 0; 
			buffer <= 0; 
		end
		else 
		begin 
			state <= state_next; 
			acc_tick <= acc_tick_next; 
			num_bits <= num_bits_next; 
			buffer <= buffer_next; 
		end
	end 

	// lógica próxima estado
	always @(*) 
	begin 
		state_next = state; 
		rx_done_tick = 1'b 0; 
		acc_tick_next = acc_tick;
		num_bits_next = num_bits; 
		buffer_next = buffer; 

		case (state)
			IDLE : 
				if (~rx) 
				begin 
					state_next = START; 
					acc_tick_next = 0; 
				end 
			
			START : 
				if (tick) 
				begin
					if (acc_tick==(NUM_TICKS>>1)-1) 
					begin 
						state_next = DATA; 
						acc_tick_next = 0; 
						num_bits_next = 0; 
					end 
					else 
						acc_tick_next = acc_tick + 1;
                end
			
			DATA : 
				if (tick)
				begin
					if (acc_tick==NUM_TICKS-1)
					begin 
						acc_tick_next = 0; 
						buffer_next = {rx , buffer [LEN_DATA-1 : 1]}; 
						if (num_bits==(LEN_DATA-1)) 
							state_next = STOP; 
						else 
							num_bits_next = num_bits + 1; 
					end 
					else
						acc_tick_next = acc_tick + 1;
			    end

			STOP : 
				if (tick)
				begin
					if (acc_tick==(NUM_TICKS-1)) 
					begin 
						state_next = IDLE; 
						rx_done_tick =1'b 1; 
					end 
					else 
						acc_tick_next = acc_tick + 1;
                end

            default :
            begin
				state_next = IDLE; 
				acc_tick_next = 0; 
				num_bits_next = 0; 
				buffer_next = 0;
			end
        endcase
	end 
endmodule