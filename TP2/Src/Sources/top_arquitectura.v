`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 2. UART.
// TOP.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////


`define BUS_DATOS_ALU       8       // Tamanio del bus de entrada. 
`define BUS_SALIDA_ALU      8       // Tamanio del bus de salida.
`define CANT_BIT_OPCODE     8       // Numero de bits del codigo de operacion de la ALU.
`define WIDTH_WORD_TOP      8       // Tamanio de palabra.    
`define FREC_CLK_MHZ    100.0       // Frecuencia del clock en MHZ.
`define BAUD_RATE_TOP    9600       // Baud rate.
`define CANT_BIT_STOP_TOP   2       // Cantidad de bits de parada en trama uart.     

module top_arquitectura(
  i_clock, 
  i_reset,
  uart_txd_in,
  uart_rxd_out,
  o_leds 
  );

// Parametros
parameter BUS_DATOS_ALU     = `BUS_DATOS_ALU;
parameter BUS_SALIDA_ALU    = `BUS_SALIDA_ALU;
parameter CANT_BIT_OPCODE   = `CANT_BIT_OPCODE;
parameter WIDTH_WORD_TOP    = `WIDTH_WORD_TOP;
parameter FREC_CLK_MHZ      = `FREC_CLK_MHZ;
parameter BAUD_RATE_TOP     = `BAUD_RATE_TOP;
parameter CANT_BIT_STOP_TOP = `CANT_BIT_STOP_TOP;

// Entradas - Salidas
input i_clock;                                  // Clock.
input i_reset;                                  // Reset.
input uart_txd_in;                              // Transmisor de PC.
output uart_rxd_out;                            // Receptor de PC.
output [4 - 1 : 0] o_leds;             // Leds.



// Wires.
wire [BUS_DATOS_ALU - 1 : 0]    wire_operando_1;
wire [BUS_DATOS_ALU - 1 : 0]    wire_operando_2;
wire [CANT_BIT_OPCODE - 1 : 0]  wire_opcode;
wire [BUS_SALIDA_ALU - 1 : 0]   wire_resultado_alu;
wire [WIDTH_WORD_TOP - 1 : 0]   wire_data_rx;
wire [WIDTH_WORD_TOP - 1 : 0]   wire_data_tx;
wire wire_tx_done;
wire wire_rx_done;
wire wire_tx_start;
wire wire_rate_baud_generator;

wire prueba;
assign o_leds = prueba;

// Modulo interface_circuit.

interface_circuit
    #(
         .CANT_DATOS_ENTRADA_ALU (BUS_DATOS_ALU),
         .CANT_BITS_OPCODE_ALU (CANT_BIT_OPCODE),
         .CANT_DATOS_SALIDA_ALU (BUS_SALIDA_ALU),
         .WIDTH_WORD_INTERFACE (WIDTH_WORD_TOP)
     ) 
   u_interface_circuit1    // Una sola instancia de este modulo
   (
   .i_clock (i_clock),
   .i_reset (i_reset),
   .i_resultado_alu (wire_resultado_alu),
   .i_data_rx (wire_data_rx),
   .i_tx_done (wire_tx_done),
   .i_rx_done (wire_rx_done),
   .o_tx_start (wire_tx_start),
   .o_data_tx (wire_data_tx),
   .o_reg_dato_A (wire_operando_1),
   .o_reg_dato_B (wire_operando_2),
   .o_reg_opcode (wire_opcode),
   .o_prueba (prueba)
   );
   

// Modulo baud_rate_generator  
baud_rate_generator
       #(
            .BAUD_RATE (BAUD_RATE_TOP),
            .FREC_CLOCK_MHZ (FREC_CLK_MHZ)
        ) 
    u_baud_rate_generator1    // Una sola instancia de este modulo
    (
    .i_clock (i_clock),
    .i_reset (i_reset),
    .o_rate (wire_rate_baud_generator)
    );
      
// Modulo receptor      
rx
        #(
            .WIDTH_WORD (WIDTH_WORD_TOP),
            .CANT_BIT_STOP (CANT_BIT_STOP_TOP)
        ) 
    u_rx1    // Una sola instancia de este modulo
    (
    .i_clock (i_clock),
    .i_rate (wire_rate_baud_generator),
    .i_bit_rx (uart_txd_in),
    .i_reset (i_reset),
    .o_rx_done (wire_rx_done),
    .o_data_out (wire_data_rx)
    );


// Modulo transmisor.
tx
        #(
            .WIDTH_WORD_TX (WIDTH_WORD_TOP),
            .CANT_BIT_STOP (CANT_BIT_STOP_TOP)
        ) 
    u_tx1    // Una sola instancia de este modulo
    (
    .i_clock (i_clock),
    .i_rate (wire_rate_baud_generator),
    .i_reset (i_reset),
    .i_data_in (wire_data_tx),
    .i_tx_start (wire_tx_start),
    .o_bit_tx (uart_rxd_out),
    .o_tx_done (wire_tx_done)
    );


// Modulo ALU.

alu
        #(
            .CANT_BUS_ENTRADA (BUS_DATOS_ALU),
            .CANT_BUS_SALIDA (BUS_SALIDA_ALU),
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
