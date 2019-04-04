`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// ALU.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////////////////////

module alu
   #(
       
       parameter CANT_BITS_ALU_CONTROL = 4
    
    )
   (
       input [CANT_BITS_ALU_CONTROL - 1 : 0]  i_ALUCtrl,
       output reg o_MemtoReg     
   );


   /* Control general */
   always@(*) begin
    case (i_ALUCtrl) //6 bits LSB.
        4'b1011://SLL
            begin 
                //COMPLETAR
            end
        4'b1100://SRL
            begin
                //COMPLETAR
            end
        4'b1101://SRA
            begin
                //COMPLETAR
            end
        4'b1011://SLLV
            begin
                //COMPLETAR
            end
        4'b1100://SRLV
            begin
                //COMPLETAR
            end
        4'b1101://SRAV
            begin
                //COMPLETAR
            end
        4'b0010://ADDU //ADDI
            begin
                //COMPLETAR
            end
        4'b0110://SUBU
            begin
                //COMPLETAR
            end
        4'b0000://AND //ANDI
            begin
                //COMPLETAR
            end
        4'b0001://OR //ORI
            begin
                //COMPLETAR
            end
        4'b1001://XOR //XORI
            begin
                //COMPLETAR
            end
        4'b1010://NOR
            begin
                //COMPLETAR
            end
        4'b0111://SLT //SLTI
            begin
                //COMPLETAR
            end


        default:
            begin
                //COMPLETAR
            end
    endcase
   end