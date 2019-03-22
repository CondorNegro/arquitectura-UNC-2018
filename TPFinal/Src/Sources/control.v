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




always@(*) begin
    if (i_instruction [CANT_BITS_INSTRUCCION - 1 : CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL -  1] == {CANT_BITS_ESPECIAL{1'b0}}) //6 bits MSB en cero.
        case (i_instruction [CANT_BITS_ID_LSB - 1 : 0]) //6 bits LSB.
            0://SLL
                begin 
                    o_reg_A = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 3 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB];
                    o_reg_B = 0;
                    o_reg_W = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB];
                    o_flag_branch = 3'b000;
                    o_immediate = i_instruction [CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB - 1 : CANT_BITS_ID_LSB];
                    o_instruction_index_branch = 0;
                end
            2://SRL
                begin
                    o_reg_A = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 3 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB];
                    o_reg_B = 0;
                    o_reg_W = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB];
                    o_flag_branch = 3'b000;
                    o_immediate = i_instruction [CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB - 1 : CANT_BITS_ID_LSB];
                    o_instruction_index_branch = 0;
                end
            3://SRA
                begin
                    o_reg_A = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 3 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB];
                    o_reg_B = 0;
                    o_reg_W = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB];
                    o_flag_branch = 3'b000;
                    o_immediate = i_instruction [CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB - 1 : CANT_BITS_ID_LSB];
                    o_instruction_index_branch = 0;
                end
            4://SLLV
                begin
                    o_reg_A = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 3 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB];
                    o_reg_B = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_W = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB];
                    o_flag_branch = 3'b000;
                    o_immediate = 0;
                    o_instruction_index_branch = 0;
                end
            6://SRLV
                begin
                    o_reg_A = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 3 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB];
                    o_reg_B = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_W = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB];
                    o_flag_branch = 3'b000;
                    o_immediate = 0;
                    o_instruction_index_branch = 0;
                end
            7://SRAV
                begin
                    o_reg_A = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 3 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB];
                    o_reg_B = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_W = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB];
                    o_flag_branch = 3'b000;
                    o_immediate = 0;
                    o_instruction_index_branch = 0;
                end
            33://ADDU
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 3 + CANT_BITS_ID_LSB - 1:
                     CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB];
                    o_reg_W = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB];
                    o_flag_branch = 3'b000;
                    o_immediate = 0;
                    o_instruction_index_branch = 0;
                end
            35://SUBU
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 3 + CANT_BITS_ID_LSB - 1:
                     CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB];
                    o_reg_W = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB];
                    o_flag_branch = 3'b000;
                    o_immediate = 0;
                    o_instruction_index_branch = 0;
                end
            36://AND
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 3 + CANT_BITS_ID_LSB - 1:
                     CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB];
                    o_reg_W = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB];
                    o_flag_branch = 3'b000;
                    o_immediate = 0;
                    o_instruction_index_branch = 0;
                end
            37://OR
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 3 + CANT_BITS_ID_LSB - 1:
                     CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB];
                    o_reg_W = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB];
                    o_flag_branch = 3'b000;
                    o_immediate = 0;
                    o_instruction_index_branch = 0;
                end
            38://XOR
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 3 + CANT_BITS_ID_LSB - 1:
                     CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB];
                    o_reg_W = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB];
                    o_flag_branch = 3'b000;
                    o_immediate = 0;
                    o_instruction_index_branch = 0;
                end
            39://NOR
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 3 + CANT_BITS_ID_LSB - 1:
                     CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB];
                    o_reg_W = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB];
                    o_flag_branch = 3'b000;
                    o_immediate = 0;
                    o_instruction_index_branch = 0;
                end
            42://SLT
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 3 + CANT_BITS_ID_LSB - 1:
                     CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB];
                    o_reg_W = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB - 1:
                     CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB];
                    o_flag_branch = 3'b000;
                    o_immediate = 0;
                    o_instruction_index_branch = 0;
                end
            8://JR
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = 0;
                    o_reg_W = 0;
                    o_flag_branch = 3'b001;
                    o_immediate = 0;
                    o_instruction_index_branch = 0;
                end
            9://JALR 
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = 0;
                    o_reg_W = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB - 1:
                     CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB];
                    o_flag_branch = 3'b010;
                    o_immediate = 0;
                    o_instruction_index_branch = 0;
                end
            default:
                begin
                    o_reg_A = 0;
                    o_reg_B = 0;
                    o_reg_W = 0;
                    o_flag_branch = 3'b000;
                    o_immediate = 0;
                    o_instruction_index_branch = 0;
                end
        endcase
    else begin // 6 bits MSB distinto de cero.
      case (i_instruction [CANT_BITS_INSTRUCCION - 1 : CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL -  1])//6 bits MSB.
            32://LB
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = 0;
                    o_reg_W = i_instruction [CANT_BITS_IMMEDIATE + CANT_BITS_ADDRESS_REGISTROS - 1:
                     CANT_BITS_IMMEDIATE];
                    o_flag_branch = 3'b000;
                    o_immediate = i_instruction [CANT_BITS_IMMEDIATE - 1 : 0];
                    o_instruction_index_branch = 0;
                end
            33://LH
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = 0;
                    o_reg_W = i_instruction [CANT_BITS_IMMEDIATE + CANT_BITS_ADDRESS_REGISTROS - 1:
                     CANT_BITS_IMMEDIATE];
                    o_flag_branch = 3'b000;
                    o_immediate = i_instruction [CANT_BITS_IMMEDIATE - 1 : 0];
                    o_instruction_index_branch = 0;
                end
            35://LW
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = 0;
                    o_reg_W = i_instruction [CANT_BITS_IMMEDIATE + CANT_BITS_ADDRESS_REGISTROS - 1:
                     CANT_BITS_IMMEDIATE];
                    o_flag_branch = 3'b000;
                    o_immediate = i_instruction [CANT_BITS_IMMEDIATE - 1 : 0];
                    o_instruction_index_branch = 0;
                end
            39://LWU
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = 0;
                    o_reg_W = i_instruction [CANT_BITS_IMMEDIATE + CANT_BITS_ADDRESS_REGISTROS - 1:
                     CANT_BITS_IMMEDIATE];
                    o_flag_branch = 3'b000;
                    o_immediate = i_instruction [CANT_BITS_IMMEDIATE - 1 : 0];
                    o_instruction_index_branch = 0;
                end
            36://LBU
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = 0;
                    o_reg_W = i_instruction [CANT_BITS_IMMEDIATE + CANT_BITS_ADDRESS_REGISTROS - 1:
                     CANT_BITS_IMMEDIATE];
                    o_flag_branch = 3'b000;
                    o_immediate = i_instruction [CANT_BITS_IMMEDIATE - 1 : 0];
                    o_instruction_index_branch = 0;
                end
            37://LHU
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = 0;
                    o_reg_W = i_instruction [CANT_BITS_IMMEDIATE + CANT_BITS_ADDRESS_REGISTROS - 1:
                     CANT_BITS_IMMEDIATE];
                    o_flag_branch = 3'b000;
                    o_immediate = i_instruction [CANT_BITS_IMMEDIATE - 1 : 0];
                    o_instruction_index_branch = 0;
                end
            40://SB
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = 0;
                    o_reg_W = i_instruction [CANT_BITS_IMMEDIATE + CANT_BITS_ADDRESS_REGISTROS - 1:
                     CANT_BITS_IMMEDIATE];
                    o_flag_branch = 3'b000;
                    o_immediate = i_instruction [CANT_BITS_IMMEDIATE - 1 : 0];
                    o_instruction_index_branch = 0;
                end
            41://SH
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = 0;
                    o_reg_W = i_instruction [CANT_BITS_IMMEDIATE + CANT_BITS_ADDRESS_REGISTROS - 1:
                     CANT_BITS_IMMEDIATE];
                    o_flag_branch = 3'b000;
                    o_immediate = i_instruction [CANT_BITS_IMMEDIATE - 1 : 0];
                    o_instruction_index_branch = 0;
                end
            43://SW
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = 0;
                    o_reg_W = i_instruction [CANT_BITS_IMMEDIATE + CANT_BITS_ADDRESS_REGISTROS - 1:
                     CANT_BITS_IMMEDIATE];
                    o_flag_branch = 3'b000;
                    o_immediate = i_instruction [CANT_BITS_IMMEDIATE - 1 : 0];
                    o_instruction_index_branch = 0;
                end
            8://ADDI
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = 0;
                    o_reg_W = i_instruction [CANT_BITS_IMMEDIATE + CANT_BITS_ADDRESS_REGISTROS - 1:
                     CANT_BITS_IMMEDIATE];
                    o_flag_branch = 3'b000;
                    o_immediate = i_instruction [CANT_BITS_IMMEDIATE - 1 : 0];
                    o_instruction_index_branch = 0;
                end
            12://ANDI
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = 0;
                    o_reg_W = i_instruction [CANT_BITS_IMMEDIATE + CANT_BITS_ADDRESS_REGISTROS - 1:
                     CANT_BITS_IMMEDIATE];
                    o_flag_branch = 3'b000;
                    o_immediate = i_instruction [CANT_BITS_IMMEDIATE - 1 : 0];
                    o_instruction_index_branch = 0;
                end
            13://ORI
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = 0;
                    o_reg_W = i_instruction [CANT_BITS_IMMEDIATE + CANT_BITS_ADDRESS_REGISTROS - 1:
                     CANT_BITS_IMMEDIATE];
                    o_flag_branch = 3'b000;
                    o_immediate = i_instruction [CANT_BITS_IMMEDIATE - 1 : 0];
                    o_instruction_index_branch = 0;
                end
            14://XORI
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = 0;
                    o_reg_W = i_instruction [CANT_BITS_IMMEDIATE + CANT_BITS_ADDRESS_REGISTROS - 1:
                     CANT_BITS_IMMEDIATE];
                    o_flag_branch = 3'b000;
                    o_immediate = i_instruction [CANT_BITS_IMMEDIATE - 1 : 0];
                    o_instruction_index_branch = 0;
                end
            15://LUI
                begin
                    o_reg_A = 0;
                    o_reg_B = 0;
                    o_reg_W = i_instruction [CANT_BITS_IMMEDIATE + CANT_BITS_ADDRESS_REGISTROS - 1:
                     CANT_BITS_IMMEDIATE];
                    o_flag_branch = 3'b000;
                    o_immediate = i_instruction [CANT_BITS_IMMEDIATE - 1 : 0];
                    o_instruction_index_branch = 0;
                end
            10://SLTI
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = 0;
                    o_reg_W = i_instruction [CANT_BITS_IMMEDIATE + CANT_BITS_ADDRESS_REGISTROS - 1:
                     CANT_BITS_IMMEDIATE];
                    o_flag_branch = 3'b000;
                    o_immediate = i_instruction [CANT_BITS_IMMEDIATE - 1 : 0];
                    o_instruction_index_branch = 0;
                end
            4://BEQ
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = i_instruction [CANT_BITS_IMMEDIATE + CANT_BITS_ADDRESS_REGISTROS - 1:
                     CANT_BITS_IMMEDIATE];
                    o_reg_W = 0;
                    o_flag_branch = 3'b011;
                    o_immediate = i_instruction [CANT_BITS_IMMEDIATE - 1 : 0];
                    o_instruction_index_branch = 0;
                end
            5://BNE
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = i_instruction [CANT_BITS_IMMEDIATE + CANT_BITS_ADDRESS_REGISTROS - 1:
                     CANT_BITS_IMMEDIATE];
                    o_reg_W = 0;
                    o_flag_branch = 3'b100;
                    o_immediate = i_instruction [CANT_BITS_IMMEDIATE - 1 : 0];
                    o_instruction_index_branch = 0;
                end
            2://J
                begin
                    o_reg_A = 0;
                    o_reg_B = 0;
                    o_reg_W = 0;
                    o_flag_branch = 3'b101;
                    o_immediate = 0;
                    o_instruction_index_branch = i_instruction [CANT_BITS_INSTRUCTION_INDEX_BRANCH - 1 : 0];
                end
            3://JAL
                begin
                    o_reg_A = 0;
                    o_reg_B = 0;
                    o_reg_W = 0;
                    o_flag_branch = 3'b101;
                    o_immediate = 0;
                    o_instruction_index_branch = i_instruction [CANT_BITS_INSTRUCTION_INDEX_BRANCH - 1 : 0];
                end
            default:
                begin
                    o_reg_A = 0;
                    o_reg_B = 0;
                    o_reg_W = 0;
                    o_flag_branch = 3'b000;
                    o_immediate = 0;
                    o_instruction_index_branch = 0;
                end
        endcase
    end
end



    




endmodule
