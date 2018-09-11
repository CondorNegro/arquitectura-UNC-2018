`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 1. ALU.
// TOP.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////


`define BUS_DATOS_ALU       8     // Tamanio del bus de entrada. (Por ejemplo, cantidad de switches).
`define BUS_SALIDA_ALU      8     // Tamanio del bus de salida. (Por ejemplo, cantidad de leds).
`define CANT_BIT_OPCODE     8     // Numero de bits del codigo de operacion de la ALU.
`define WIDTH_WORD          8     // Tamanio de palabra
`define CANT_BIT_STOP       2     // Cantidad de bit de parada

module top_arquitectura(
  i_clock, 
  i_reset,
  i_rx_uart,
  o_tx_uart 
  //o_leds 
  );

// Parametros
parameter BUS_DATOS_ALU = `BUS_DATOS_ALU;
parameter BUS_SALIDA_ALU = `BUS_SALIDA_ALU;
parameter CANT_BIT_OPCODE = `CANT_BIT_OPCODE;
parameter WIDTH_WORD = `WIDTH_WORD;
parameter CANT_BIT_STOP = `CANT_BIT_STOP;


// Entradas - Salidas
input i_clock;                                  // Clock.
input i_reset;                                  // Reset.
input i_rx_uart;          
output o_tx_uart;
//output [BUS_SALIDA_ALU - 1 : 0] o_leds;             // Leds.



// Wires.
wire [BUS_DATOS_ALU - 1 : 0] wire_operando_1;
wire [BUS_DATOS_ALU - 1 : 0] wire_operando_2;
wire [CANT_BIT_OPCODE - 1 : 0] wire_opcode;
wire [BUS_SALIDA_ALU - 1 : 0] wire_resultado_alu;
wire [WIDTH_WORD - 1 : 0] wire_data_rx;
wire [WIDTH_WORD - 1 : 0] wire_data_tx;
wire wire_tx_done;
wire wire_rx_done;
wire wire_tx_start;


// Modulo Configurador. (Logica de seteo de operandos y del codigo de operacion en los registros).

interface_circuit
    #(
         .CANT_DATOS_ENTRADA_ALU (BUS_DATOS_ALU),
         .CANT_BITS_OPCODE_ALU (CANT_BIT_OPCODE),
         .CANT_DATOS_SALIDA_ALU (BUS_SALIDA_ALU),
         .WIDTH_WORD (WIDTH_WORD)
     ) 
   u_interface_circuit1    // Una sola instancia de este modulo
   (
   .i_clock (i_clock),
   .i_reset (i_reset),
   .i_resultado_alu (wire_resultado_alu),
   .i_data_rx (wire_data_rx),
   .i_tx_done (wire_tx_done),
   .i_rx_done (wire_tx_done),
   .o_tx_start (wire_tx_start),
   .o_data_tx (wire_data_tx),
   .o_reg_dato_A (wire_operando_1),
   .o_reg_dato_B (wire_operando_2),
   .o_reg_opcode (wire_opcode)
   );


// Modulo ALU.

alu
    #(
         .CANT_BUS_ENTRADA (BUS_DATOS_ALU),
         .CANT_BUS_SALIDA_ALU (BUS_SALIDA_ALU),
         .CANT_BITS_OPCODE (CANT_BIT_OPCODE)
     ) 
   u_alu1    // Una sola instancia de este modulo
   (
   .i_operando_1 (wire_operando_1),
   .i_operando_2 (wire_operando_2),
   .i_opcode (wire_opcode),
   .o_resultado (wire_resultado_alu)
   );




endmodule
