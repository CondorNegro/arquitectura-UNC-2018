`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Práctico N° 1. ALU.
// TOP.
// Integrantes: Kleiner Matías, López Gastón.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Año 2018.
//////////////////////////////////////////////////////////////////////////////////


`define BUS_DATOS           4   // Tamaño del bus de entrada. (Por ejemplo, cantidad de switches).
`define BUS_SALIDA          4   // Tamaño del bus de salida. (Por ejemplo, cantidad de leds).
`define CANT_BOTONES_ALU    4   // Cantidad de botones.

module top_arquitectura(
  i_clock, 
  i_reset, 
  i_switches,
  i_botones,
  o_leds 
  );

// Parámetros
parameter BUS_DATOS = `BUS_DATOS;
parameter BUS_SALIDA = `BUS_SALIDA;
parameter CANT_BOTONES_ALU = `CANT_BOTONES_ALU;

// Entradas - Salidas
input i_clock;                                  // Clock.
input i_reset;                                  // Reset.
input [BUS_DATOS - 1 : 0] i_switches;             // Switches.
input [CANT_BOTONES_ALU - 1 : 0] i_botones;     // Botones.
output [BUS_SALIDA - 1 : 0] o_leds;             // Leds.



// Wires.
wire wire_clock;                                  
wire wire_reset;
wire [BUS_DATOS - 1 : 0] wire_switches;             
wire [CANT_BOTONES_ALU - 1 : 0] wire_botones;     
wire [BUS_SALIDA - 1 : 0] wire_leds;

// Assign.
assign wire_clock = i_clock;
assign wire_reset = i_reset;
assign wire_switches = i_switches;
assign wire_botones = i_botones;
assign wire_leds = o_leds;

// Módulo ALU.
alu
    #(
         .CANT_SWITCHES (BUS_DATOS),
         .CANT_LEDS (BUS_SALIDA),
         .CANT_BOTONES (CANT_BOTONES_ALU)
     ) 
   u_alu1    // Una sola instancia de este módulo
   (
   .i_clock (wire_clock),
   .i_reset (wire_reset),
   .i_switch (wire_switches),
   .i_enable (wire_botones),
   .o_leds (wire_leds)
   );
    

endmodule
