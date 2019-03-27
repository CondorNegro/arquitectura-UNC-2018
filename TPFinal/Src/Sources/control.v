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
          o_ALUOp <= 0;
          o_MemRead <= 0;
          o_MemWrite <= 0;
          o_MemtoReg <= 0;
        end
        else begin
            if (i_instruction [CANT_BITS_INSTRUCTION - 1 : CANT_BITS_INSTRUCTION - CANT_BITS_ESPECIAL -  1] == {CANT_BITS_ESPECIAL{1'b0}}) //6 bits MSB en cero.
            begin 
                case (i_instruction [CANT_BITS_ID_LSB - 1 : 0]) //6 bits LSB.
                    0://SLL
                        begin 
                            
                        end
                    2://SRL
                        begin
                            
                        end
                    3://SRA
                        begin
                            
                        end
                    4://SLLV
                        begin
                            
                        end
                    6://SRLV
                        begin
                            
                        end
                    7://SRAV
                        begin
                            
                        end
                    33://ADDU
                        begin
                            
                        end
                    35://SUBU
                        begin
                            
                        end
                    36://AND
                        begin
                            
                        end
                    37://OR
                        begin
                            
                        end
                    38://XOR
                        begin
                            
                        end
                    39://NOR
                        begin
                            
                        end
                    42://SLT
                        begin
                            
                        end
                    8://JR
                        begin
                            
                        end
                    9://JALR 
                        begin
                            
                        end
                    default:
                        begin
                            
                        end
                endcase
            end
            else begin // 6 bits MSB distinto de cero.
              case (i_instruction [CANT_BITS_INSTRUCTION - 1 : CANT_BITS_INSTRUCTION - CANT_BITS_ESPECIAL -  1])//6 bits MSB.
                    32://LB
                        begin
                            
                        end
                    33://LH
                        begin
                           
                        end
                    35://LW
                        begin
                            
                        end
                    39://LWU
                        begin
                            
                        end
                    36://LBU
                        begin
                            
                        end
                    37://LHU
                        begin
                            
                        end
                    40://SB
                        begin
                            
                        end
                    41://SH
                        begin
                            
                        end
                    43://SW
                        begin
                           
                        end
                    8://ADDI
                        begin
                            
                        end
                    12://ANDI
                        begin
                            
                        end
                    13://ORI
                        begin
                            
                        end
                    14://XORI
                        begin
                            
                        end
                    15://LUI
                        begin
                           
                        end
                    10://SLTI
                        begin
                           
                        end
                    4://BEQ
                        begin
                          
                        end
                    5://BNE
                        begin
                           
                        end
                    2://J
                        begin
                        
                        end
                    3://JAL
                        begin
                            
                          
                        end
                    default:
                        begin
                            
                        end
                endcase
            end    
        end
   end




always@(*) begin
    
end



    




endmodule
