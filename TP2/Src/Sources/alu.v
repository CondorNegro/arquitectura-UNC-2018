`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 2. UART.
// ALU.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////

// Constantes.
`define CANT_BUS_ENTRADA    8
`define CANT_BUS_SALIDA     8
`define CANT_BITS_OPCODE    8

module alu(
    i_operando_1, 
    i_operando_2,
    i_opcode,
    o_resultado
    );

// Parametros.
parameter CANT_BUS_ENTRADA  = `CANT_BUS_ENTRADA;
parameter CANT_BUS_SALIDA   = `CANT_BUS_SALIDA;
parameter CANT_BITS_OPCODE  = `CANT_BITS_OPCODE;


// Entradas - Salidas.

input signed [CANT_BUS_ENTRADA - 1 : 0] i_operando_1;     
input signed [CANT_BUS_ENTRADA - 1 : 0] i_operando_2; 
input [CANT_BITS_OPCODE - 1 : 0] i_opcode;             // Codigo de operacion.
output signed [CANT_BUS_SALIDA - 1 : 0] o_resultado;                


// Registro.
reg signed [CANT_BUS_SALIDA - 1 : 0] reg_resultado;

// Combinacional.
always@(i_opcode or i_operando_1 or i_operando_2) begin
         
        // Case donde se testea el valor del codigo de operacion y en base a eso se opera entre operando1 y operando2.
        // Operaciones basadas en MIPS IV Instruction Set.
        case (i_opcode)
            
            //ADD
            8'b00100000 : begin
               reg_resultado = i_operando_1 + i_operando_2;
            end
             
             //SUB
             8'b00100010 : begin
               reg_resultado = i_operando_1 - i_operando_2;
             end
            
            //AND
             8'b00100100 : begin
                reg_resultado = i_operando_1 & i_operando_2;
             end
             
             //OR
             8'b00100101 : begin
                reg_resultado = i_operando_1 | i_operando_2;
             end
            
            //XOR
             8'b00100110 : begin
               reg_resultado = i_operando_1 ^ i_operando_2;
             end
             
             //SRA (Shift Right Aritmethic).
             8'b00000011 : begin
                reg_resultado = i_operando_1 >>> i_operando_2;
             end
                         
            //SRL  (Shift Right Logical).
            8'b00000010 : begin
                reg_resultado = i_operando_1 >> i_operando_2;
            end
            
            //NOR
            8'b00100111 : begin
                reg_resultado = ~ (i_operando_1 | i_operando_2);
            end
            
            default : begin
                reg_resultado = i_operando_1;
            end
            
        endcase

end

// Asignacion.
assign o_resultado = reg_resultado;

endmodule

