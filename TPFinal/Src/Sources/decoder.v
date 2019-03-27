`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Decoder.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////////////////////


module decoder
    #(
        parameter CANT_BITS_INSTRUCCION = 32,
        parameter CANT_BITS_ADDRESS_REGISTROS = 5,
        parameter CANT_BITS_IMMEDIATE = 16,
        parameter CANT_BITS_ESPECIAL = 6,
        parameter CANT_BITS_CEROS = 5,
        parameter CANT_BITS_ID_LSB = 6,
        parameter CANT_BITS_INSTRUCTION_INDEX_BRANCH = 26,
        parameter CANT_BITS_FLAG_BRANCH = 3 
    )
    (
        input [CANT_BITS_INSTRUCCION - 1 : 0] i_instruction,
        output reg [CANT_BITS_ADDRESS_REGISTROS - 1 : 0] o_reg_A,
        output reg [CANT_BITS_ADDRESS_REGISTROS - 1 : 0] o_reg_B,
        output reg [CANT_BITS_ADDRESS_REGISTROS - 1 : 0] o_reg_W,
        output reg [CANT_BITS_FLAG_BRANCH - 1 : 0] o_flag_branch, 
        output reg [CANT_BITS_IMMEDIATE - 1 : 0] o_immediate,
        output reg [CANT_BITS_INSTRUCTION_INDEX_BRANCH - 1 : 0] o_instruction_index_branch
    );


always@(*) begin
    if (i_instruction [CANT_BITS_INSTRUCCION - 1 : CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL -  1] == {CANT_BITS_ESPECIAL{1'b0}}) //6 bits MSB en cero.
    begin
       case (i_instruction [CANT_BITS_ID_LSB - 1 : 0]) //6 bits LSB.
        
            0://SLL
                begin 
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 3 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB];
                    o_reg_W = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB];
                    o_flag_branch = 3'b000;
                    o_immediate = i_instruction [CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB - 1 : CANT_BITS_ID_LSB];
                    o_instruction_index_branch = i_instruction [CANT_BITS_INSTRUCTION_INDEX_BRANCH - 1 : 0];
                end
            2://SRL
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 3 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB];
                    o_reg_W = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB];
                    o_flag_branch = 3'b000;
                    o_immediate = i_instruction [CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB - 1 : CANT_BITS_ID_LSB];
                    o_instruction_index_branch = i_instruction [CANT_BITS_INSTRUCTION_INDEX_BRANCH - 1 : 0];
                end
            3://SRA
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 3 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB];
                    o_reg_W = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB];
                    o_flag_branch = 3'b000;
                    o_immediate = i_instruction [CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB - 1 : CANT_BITS_ID_LSB];
                    o_instruction_index_branch = i_instruction [CANT_BITS_INSTRUCTION_INDEX_BRANCH - 1 : 0];
                end
            8://JR
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 3 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB];
                    o_reg_W = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB];
                    o_flag_branch = 3'b001;
                    o_immediate = i_instruction [CANT_BITS_IMMEDIATE - 1 : 0];
                    o_instruction_index_branch = i_instruction [CANT_BITS_INSTRUCTION_INDEX_BRANCH - 1 : 0];
                end
            9://JALR 
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 3 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB];
                    o_reg_W = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB - 1:
                     CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB];
                    o_flag_branch = 3'b010;
                    o_immediate = i_instruction [CANT_BITS_IMMEDIATE - 1 : 0];
                    o_instruction_index_branch = i_instruction [CANT_BITS_INSTRUCTION_INDEX_BRANCH - 1 : 0];
                end
            default:
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 3 + CANT_BITS_ID_LSB - 1:
                     CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB];
                    o_reg_W = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB - 1:
                     CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB];
                    o_flag_branch = 3'b000;
                    o_immediate = i_instruction [CANT_BITS_IMMEDIATE - 1 : 0];
                    o_instruction_index_branch = i_instruction [CANT_BITS_INSTRUCTION_INDEX_BRANCH - 1 : 0];
                end
       endcase
    end 
    else begin // 6 bits MSB distinto de cero.
      case (i_instruction [CANT_BITS_INSTRUCCION - 1 : CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL -  1])//6 bits MSB.
            4://BEQ
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 3 + CANT_BITS_ID_LSB - 1:
                     CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB];
                    o_reg_W = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB - 1:
                     CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB];
                    o_flag_branch = 3'b011;
                    o_immediate = i_instruction [CANT_BITS_IMMEDIATE - 1 : 0];
                    o_instruction_index_branch = i_instruction [CANT_BITS_INSTRUCTION_INDEX_BRANCH - 1 : 0];
                end
            5://BNE
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 3 + CANT_BITS_ID_LSB - 1:
                     CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB];
                    o_reg_W = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB - 1:
                     CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB];
                    o_flag_branch = 3'b100;
                    o_immediate = i_instruction [CANT_BITS_IMMEDIATE - 1 : 0];
                    o_instruction_index_branch = i_instruction [CANT_BITS_INSTRUCTION_INDEX_BRANCH - 1 : 0];
                end
            2://J
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 3 + CANT_BITS_ID_LSB - 1:
                     CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB];
                    o_reg_W = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB - 1:
                     CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB];
                    o_flag_branch = 3'b101;
                    o_immediate = i_instruction [CANT_BITS_IMMEDIATE - 1 : 0];
                    o_instruction_index_branch = i_instruction [CANT_BITS_INSTRUCTION_INDEX_BRANCH - 1 : 0];
                end
            3://JAL
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 3 + CANT_BITS_ID_LSB - 1:
                     CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB];
                    o_reg_W = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB - 1:
                     CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB];
                    o_flag_branch = 3'b101;
                    o_immediate = i_instruction [CANT_BITS_IMMEDIATE - 1 : 0];
                    o_instruction_index_branch = i_instruction [CANT_BITS_INSTRUCTION_INDEX_BRANCH - 1 : 0];
                end
            default:
                begin
                    o_reg_A = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                    CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS];
                    o_reg_B = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 3 + CANT_BITS_ID_LSB - 1:
                     CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB];
                    o_reg_W = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB - 1:
                     CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB];
                    o_flag_branch = 3'b000;
                    o_immediate = i_instruction [CANT_BITS_IMMEDIATE - 1 : 0];
                    o_instruction_index_branch = i_instruction [CANT_BITS_INSTRUCTION_INDEX_BRANCH - 1 : 0];
                end
      endcase
    end  
end



endmodule
