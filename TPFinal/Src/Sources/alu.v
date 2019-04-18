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
       
       parameter CANT_BITS_ALU_CONTROL = 4,
       parameter CANT_BITS_DATO = 32
    
    )
   (
       input [CANT_BITS_ALU_CONTROL - 1 : 0]  i_ALUCtrl,
       input [CANT_BITS_DATO - 1 : 0]  i_datoA,
       input [CANT_BITS_DATO - 1 : 0]  i_datoB,
       output reg [CANT_BITS_DATO - 1 : 0] o_resultado
   );

   reg signed [CANT_BITS_DATO - 1 : 0]  reg_signed_datoA;
   reg signed [CANT_BITS_DATO - 1 : 0]  reg_signed_datoB;


    always@(*) begin
      reg_signed_datoA = i_datoA;
      reg_signed_datoB = i_datoB;
    end
    

   
   always@(*) begin
        case (i_ALUCtrl) 
            4'b1011://SLL //SLLV
                begin 
                    o_resultado = i_datoA << i_datoB;
                end
            4'b1100://SRL //SRLV
                begin
                    o_resultado = i_datoA >> i_datoB;
                end
            4'b1101://SRA //SRAV
                begin
                    o_resultado = reg_signed_datoA >>> i_datoB;
                end
            4'b0010://ADDU //ADDI //LOAD
                begin
                    o_resultado = i_datoA + i_datoB;
                end
            4'b0110://SUBU
                begin
                    o_resultado = i_datoA - i_datoB;
                end
            4'b0000://AND //ANDI
                begin
                    o_resultado = i_datoA & i_datoB;
                end
            4'b0001://OR //ORI
                begin
                    o_resultado = i_datoA | i_datoB;
                end
            4'b1001://XOR //XORI
                begin
                    o_resultado = i_datoA ^ i_datoB;
                end
            4'b1010://NOR
                begin
                    o_resultado = ~ (i_datoA | i_datoB);
                end
            4'b0111://SLT //SLTI 
                begin
                    o_resultado = reg_signed_datoA < reg_signed_datoB;
                end

            4'b1000://LUI 
                begin
                    o_resultado = i_datoB << 16;
                end
            
            4'b1110: //Saltos
                begin
                    o_resultado = i_datoA;
                end


            default: //ADD
                begin
                    o_resultado = i_datoA + i_datoB;
                end
        endcase
   end
endmodule