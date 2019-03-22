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
       
       parameter CANT_BITS_INSTRUCTION = 32
    
    )
   (
       input [CANT_BITS_INSTRUCTION - 1 : 0] i_instruction,

       output reg  reg_RegDst,
       output reg  reg_RegWrite,
       output reg reg_ALUSrc,
       output reg reg_MemRead,
       output reg reg_MemWrite,
       output reg reg_MemtoReg,
       output reg reg_flag_branch      
   );




    




endmodule
