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
`define CANT_BOTONES 4
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

reg [CANT_LEDS-1:0] resultado_operacion; 

always@(posedge CLK100MHZ)begin
    
    //se resetean los registros
    if (i_reset) begin
        reg_operando_1<=0;
        reg_operando_2<=0;
        reg_operacion<=0;
        reg_leds<=0;
        resultado_operacion<=0;
    end

    //si se presiona el boton 1 (001), se guarda el valor del switch en el reg operando 1
    if (i_enable==1) begin 
        reg_operando_1<=i_switch;		
    end
    
    // boton 2 (010)
    if (i_enable==2) begin 
        reg_operando_2<=i_switch;		
    end
    
    // boton 3 (100)
    if (i_enable==4) begin  
        reg_operacion<=i_switch;        
    end
    
    // boton 0 (000) - los registros mantienen su valor
    if (i_enable==4) begin  
        reg_operacion<=reg_operacion;
        reg_operando_1<=reg_operando_1;	   
        reg_operando_2<=reg_operando_2;	      
    end

    
    // TODO : hacer un case testeando el valor de la operacion y en base a eso operar operando1 y operando2.

end 

assign {o_leds}=resultado_operacion;
endmodule

