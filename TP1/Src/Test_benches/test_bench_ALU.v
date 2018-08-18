`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2016 04:45:38 PM
// Design Name: 
// Module Name: top_instancia
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
`define NBTfiltro 8
`define NBTsignal 8
`define NRObitsBER 64
`define RAM_WIDTH  16

module test_bench_ALU(

    );
    
        parameter NBTsignal=`NBTsignal;
        parameter NRObitsBER=`NRObitsBER;
        parameter RAM_WIDTH=`RAM_WIDTH;
        parameter NBTfiltro=`NBTfiltro;

		
        reg    ck_rst;
        reg    CLK100MHZ;
        reg [3:0] sw;
        reg [31:0] gpio_in;
        wire [3:0] led;
        wire gpio_out;
       
           
        
        
      initial begin
          CLK100MHZ= 1'b0;
          gpio_in=0;
          sw=0;
          ck_rst=1'b0; //El reset es normal cerrado.
          #100000000 $finish;
      end  
      
      always #2.5 CLK100MHZ=~CLK100MHZ;
       
       top_microblaze
            #(
                .NBTsignal(NBTsignal),
                .NRObitsBER(NRObitsBER),
                .RAM_WIDTH(RAM_WIDTH),
                .NBTfiltro(NBTfiltro)
             )
            u_top_microblaze
                (
                .CLK100MHZ(CLK100MHZ),
                .i_sw(sw),
                .ck_rst(ck_rst),
                .o_led(led),
                .uart_rxd_out(gpio_out),
                .uart_txd_in(gpio_in) 
                  
                );
endmodule

