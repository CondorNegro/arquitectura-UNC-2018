`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 1. ALU.
// TOP.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////


`define BUS_DATOS           4   // Tamanio del bus de entrada. (Por ejemplo, cantidad de switches).
`define BUS_SALIDA          4   // Tamanio del bus de salida. (Por ejemplo, cantidad de leds).
`define CANT_BOTONES_ALU    4   // Cantidad de botones.
`define CANT_BIT_OPCODE    4    // Numero de bits del codigo de operacion de la ALU.

module top_arquitectura(
  i_clock, 
  i_reset, 
  i_switches,
  i_botones,
  o_leds 
  );

// Parametros
parameter BUS_DATOS = `BUS_DATOS;
parameter BUS_SALIDA = `BUS_SALIDA;
parameter CANT_BOTONES_ALU = `CANT_BOTONES_ALU;
parameter CANT_BIT_OPCODE = `CANT_BIT_OPCODE;

// Entradas - Salidas
input i_clock;                                  // Clock.
input i_reset;                                  // Reset.
input [BUS_DATOS - 1 : 0] i_switches;           // Switches.
input [CANT_BOTONES_ALU - 1 : 0] i_botones;     // Botones.
output [BUS_SALIDA - 1 : 0] o_leds;             // Leds.



// Wires.
wire [BUS_DATOS - 1 : 0] wire_operando_1;
wire [BUS_DATOS - 1 : 0] wire_operando_2;
wire [CANT_BIT_OPCODE - 1 : 0] wire_opcode;


// Modulo Configurador. (Logica de seteo de operandos y del codigo de operacion en los registros).

configurador
    #(
         .CANT_DATOS_ENTRADA (BUS_DATOS),
         .CANT_BITS_OPCODE_ALU (CANT_BIT_OPCODE)
     ) 
   u_configurador1    // Una sola instancia de este modulo
   (
   .i_clock (i_clock),
   .i_reset (i_reset),
   .i_switches (i_switches),
   .i_botones (i_botones),
   .o_reg_dato_A (wire_operando_1),
   .o_reg_dato_B (wire_operando_2),
   .o_reg_opcode (wire_opcode)
   );


// Modulo ALU.

alu
    #(
         .CANT_BUS_ENTRADA (BUS_DATOS),
         .CANT_BUS_SALIDA (BUS_SALIDA),
         .CANT_BITS_OPCODE (CANT_BIT_OPCODE)
     ) 
   u_alu1    // Una sola instancia de este modulo
   (
   .i_operando_1 (wire_operando_1),
   .i_operando_2 (wire_operando_2),
   .i_opcode (wire_opcode),
   .o_resultado (o_leds)
   );




endmodule
