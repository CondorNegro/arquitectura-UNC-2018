`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Pr�ctico N� 1. ALU.
// TOP.
// Integrantes: Kleiner Mat�as, L�pez Gast�n.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// A�o 2018.
//////////////////////////////////////////////////////////////////////////////////


`define BUS_DATOS           4   // Tama�o del bus de entrada. (Por ejemplo, cantidad de switches).
`define BUS_SALIDA          4   // Tama�o del bus de salida. (Por ejemplo, cantidad de leds).
`define CANT_BOTONES_ALU    4   // Cantidad de botones.

module top_arquitectura(
  i_clock, 
  i_reset, 
  i_switches,
  i_botones,
  o_leds 
  );

// Par�metros
parameter BUS_DATOS = `BUS_DATOS;
parameter BUS_SALIDA = `BUS_SALIDA;
parameter CANT_BOTONES_ALU = `CANT_BOTONES_ALU;

// Entradas - Salidas
input i_clock;                                  // Clock.
input i_reset;                                  // Reset.
input [BUS_DATOS - 1 : 0] i_switches;           // Switches.
input [CANT_BOTONES_ALU - 1 : 0] i_botones;     // Botones.
output [BUS_SALIDA - 1 : 0] o_leds;             // Leds.



// M�dulo ALU.
alu
    #(
         .CANT_SWITCHES (BUS_DATOS),
         .CANT_LEDS (BUS_SALIDA),
         .CANT_BOTONES (CANT_BOTONES_ALU)
     ) 
   u_alu1    // Una sola instancia de este m�dulo
   (
   .i_clock (i_clock),
   .i_reset (i_reset),
   .i_switch (i_switches),
   .i_enable (i_botones),
   .o_leds (o_leds)
   );
    

endmodule
