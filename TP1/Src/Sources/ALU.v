`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.08.2018 17:02:57
// Design Name: 
// Module Name: alu
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

`define CANT_SWITCHES 4
`define CANT_BOTONES 3
`define CANT_LEDS 4

module alu(CLK100MHZ, 
              i_switch, 
              i_reset, 
              i_enable,
              o_leds);

parameter CANT_SWITCHES=`CANT_SWITCHES;
parameter CANT_BOTONES=`CANT_BOTONES;
parameter CANT_LEDS=`CANT_LEDS;

input CLK100MHZ;
input [CANT_SWITCHES-1:0] i_switch;
input i_reset;
input [CANT_BOTONES-1:0] i_enable;

output [CANT_LEDS-1:0] o_leds;

reg signed [CANT_SWITCHES-1:0] reg_operando_1;  
reg signed [CANT_SWITCHES-1:0] reg_operando_2; 
reg [CANT_SWITCHES-1:0] reg_operacion;
reg [CANT_LEDS-1:0] reg_leds; 

always@(posedge CLK100MHZ)begin
   

end 
//assign {o_symbol}=symbol;
endmodule

