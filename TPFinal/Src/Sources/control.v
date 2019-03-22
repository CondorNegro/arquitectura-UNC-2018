`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Control.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////////////////////


module control
   #(
       
       parameter CANT_BITS_INSTRUCTION = 32,
       parameter CANT_BITS_FLAG_BRANCH = 3,
       parameter CANT_BITS_ALU_OP = 2,
       parameter CANT_BITS_ESPECIAL = 6,
       parameter CANT_BITS_ID_LSB = 6
    
    )
   (
       input i_clock,
       input i_soft_reset,
       input [CANT_BITS_INSTRUCTION - 1 : 0] i_instruction,
       output reg o_RegDst,
       output reg o_RegWrite,
       output reg o_ALUSrc,
       output reg [CANT_BITS_ALU_OP - 1 : 0] o_ALUOp,
       output reg o_MemRead,
       output reg o_MemWrite,
       output reg o_MemtoReg     
   );



   always@(posedge i_clock) begin
        if (~ i_soft_reset) begin
          o_RegDst <= 0;
          o_RegWrite <= 0;
          o_ALUSrc <= 0;
          o_ALUOp <= 0
          o_MemRead <= 0;
          o_MemWrite <= 0;
          o_MemtoReg <= 0;
        end
        else begin
                
        end
   end




    




endmodule
