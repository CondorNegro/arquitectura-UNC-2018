`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Pr�ctico N� 1. ALU.
// ALU.
// Integrantes: Kleiner Mat�as, L�pez Gast�n.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// A�o 2018.
//////////////////////////////////////////////////////////////////////////////////

// Constantes.
`define CANT_BUS_ENTRADA 4
`define CANT_BUS_SALIDA 4
`define CANT_BITS_OPCODE 4

module alu(
    i_operando_1, 
    i_operando_2,
    i_opcode,
    o_resultado
    );

// Par�metros.
parameter CANT_BUS_ENTRADA = `CANT_BUS_ENTRADA;
parameter CANT_BUS_SALIDA = `CANT_BUS_SALIDA;
parameter CANT_BITS_OPCODE = `CANT_BITS_OPCODE;


// Entradas - Salidas.

input signed [CANT_BUS_ENTRADA - 1 : 0] i_operando_1;     
input signed [CANT_BUS_ENTRADA - 1 : 0] i_operando_2; 
input [CANT_BITS_OPCODE - 1 : 0] i_opcode;             // C�digo de operaci�n.
output signed [CANT_BUS_SALIDA - 1 : 0] o_resultado;                


// Registro.
reg signed [CANT_BUS_SALIDA - 1 : 0] reg_resultado;

always@(i_opcode or i_operando_1 or i_operando_2) begin
         
        // Case donde se testea el valor del c�digo de operaci�n y en base a eso se opera entre operando1 y operando2.
        // Operaciones basadas en MIPS IV Instruction Set.
        case (i_opcode)
            
            //ADD
            4'b1000 : begin
               reg_resultado = i_operando_1 + i_operando_2;
            end
             
             //SUB
             4'b1010 : begin
               reg_resultado = i_operando_1 - i_operando_2;
             end
            
            //AND
             4'b1100 : begin
                reg_resultado = i_operando_1 & i_operando_2;
             end
             
             //OR
             4'b1101 : begin
                reg_resultado = i_operando_1 | i_operando_2;
             end
            
            //XOR
             4'b1110 : begin
               reg_resultado = i_operando_1 ^ i_operando_2;
             end
             
             //SRA (Shift Right Aritmethic).
             4'b0011 : begin
                reg_resultado = i_operando_1 >>> i_operando_2;
             end
                         
            //SRL  (Shift Right Logical).
            4'b0010 : begin
                reg_resultado = i_operando_1 >> i_operando_2;
            end
            
            //NOR
            4'b1111 : begin
                reg_resultado = ~ (i_operando_1 | i_operando_2);
            end
            
            default : begin
                reg_resultado = i_operando_1;
            end
            
        endcase

end

// Asignaci�n.
assign o_resultado = reg_resultado;

endmodule

