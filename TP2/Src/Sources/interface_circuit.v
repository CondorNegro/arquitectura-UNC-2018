 `timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 1. ALU.
// Configurador. (Logica de seteo de operandos y del codigo de operacion en los registros).
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////////////////////


// Constantes.
`define CANT_DATOS_ENTRADA_ALU      8       // Tamanio del bus de entrada. (Idem a tamanio del bus de salida).
`define CANT_BITS_OPCODE_ALU        8       // Numero de bits del codigo de operacion de la ALU.
`define CANT_DATOS_SALIDA_ALU       8       // Numero de bits del codigo de operacion de la ALU.
`define WIDTH_WORD                  8       // Tamanio de palabra



module interface_circuit( 
    i_reset,
    i_resultado_alu,
    i_data_rx,
    i_rx_done,
    i_tx_done,
    o_tx_start,
    o_data_tx,
    o_reg_dato_A,
    o_reg_dato_B,
    o_reg_opcode
    );

// Parametros.
parameter CANT_DATOS_ENTRADA_ALU    = `CANT_DATOS_ENTRADA_ALU;
parameter CANT_BITS_OPCODE_ALU      = `CANT_BITS_OPCODE_ALU;
parameter CANT_DATOS_SALIDA_ALU     = `CANT_DATOS_SALIDA_ALU;
parameter CANT_DATOS_SALIDA_ALU     = `CANT_DATOS_SALIDA_ALU;


// Entradas - Salidas.

input i_clock;     
input i_reset; 
input [CANT_DATOS_ENTRADA_ALU - 1 : 0] i_switches; 
input [CANT_BOTONES_OPCODE - 1 : 0] i_botones; 
output [CANT_DATOS_ENTRADA_ALU - 1 : 0] o_reg_dato_A;             
output [CANT_DATOS_ENTRADA_ALU - 1 : 0] o_reg_dato_B; 
output [CANT_BITS_OPCODE_ALU - 1 : 0] o_reg_opcode;  // Codigo de operacion.      



// Registros.
reg [CANT_DATOS_ENTRADA_ALU - 1 : 0] reg_dato_A;
reg [CANT_DATOS_ENTRADA_ALU - 1 : 0] reg_dato_B;
reg [CANT_BITS_OPCODE_ALU - 1 : 0] reg_opcode;

always@( posedge i_clock) begin
     // Se resetean los registros.
     if (~ i_reset) begin
        reg_dato_A <= 0;
        reg_dato_B <= 0;
        reg_opcode <= 0;
     end 
     
     else begin
        // Si se presiona el boton 1
        if (i_botones == 1) begin
            reg_dato_A <= i_switches;
            reg_dato_B <= reg_dato_B;
            reg_opcode <= reg_opcode;
        end
        // Si se presiona el boton 2
        else  if (i_botones == 2) begin
           reg_dato_A <= reg_dato_A;
           reg_dato_B <= reg_dato_B;
           reg_opcode <= i_switches;
        end
        // Si se presiona el boton 3
        else  if (i_botones == 4) begin
           reg_dato_A <= reg_dato_A;
           reg_dato_B <= i_switches;
           reg_opcode <= reg_opcode;
        end
        else begin
            reg_dato_A <= reg_dato_A;
            reg_dato_B <= reg_dato_B;
            reg_opcode <= reg_opcode;
        end        
     end   
end

// Asignacion.
assign o_reg_dato_A = reg_dato_A;
assign o_reg_dato_B = reg_dato_B;
assign o_reg_opcode = reg_opcode;

endmodule


