`timescale 1ns / 1ps

`define BUS_DATOS 8 //cantidad botones y cantidad leds es el bus de datos
`define CANT_BOTONES_ALU 3 // para alu

module top_arquitectura(


  CLK100MHZ, i_reset 
  
  );

//Parametros
parameter BUS_DATOS=`BUS_DATOS;
parameter CANT_BOTONES_ALU=`CANT_BOTONES_ALU;

// entradas - salidas
input CLK100MHZ;
input i_reset;

// wire [2:0] led21;


//assign o_led0=led00&led01;


alu
    #(
         .CANT_SWITCHES(BUS_DATOS),
         .CANT_LEDS(BUS_DATOS),
         .CANT_BOTONES(CANT_BOTONES_ALU)
     ) 
   u_alu1    //una sola instancia de este modulo
   (.CLK100MHZ(CLK100MHZ),
   .i_reset(i_reset),
   .i_enable(),
   .o_leds()
   );
    

endmodule
