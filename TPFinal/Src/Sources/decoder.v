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
        parameter CANT_BITS_ID_LSB = 6
    )
    (
        input [CANT_BITS_INSTRUCCION - 1 : 0] i_instruction,
        output reg [CANT_BITS_ADDRESS_REGISTROS - 1 : 0] o_reg_A,
        output reg [CANT_BITS_ADDRESS_REGISTROS - 1 : 0] o_reg_B,
        output reg [CANT_BITS_ADDRESS_REGISTROS - 1 : 0] o_reg_W,
        output reg o_flag_branch, 
        output reg [CANT_BITS_IMMEDIATE - 1 : 0] o_immediate 
    );




always@(*) begin
    case (i_instruction [CANT_BITS_ID_LSB - 1 : 0])
        0://SLL
            begin
                o_reg_A = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 3 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB];;
                o_reg_B = 0;
                o_reg_W = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB];
                o_flag_branch = 0;
                o_immediate = i_instruction [CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB - 1 : CANT_BITS_ID_LSB];;
            end
        2://SRL
            begin
                o_reg_A = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 3 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB];;
                o_reg_B = 0;
                o_reg_W = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB];
                o_flag_branch = 0;
                o_immediate = i_instruction [CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB - 1 : CANT_BITS_ID_LSB];;
            end
        3://SRA
            begin
                o_reg_A = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 3 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB];;
                o_reg_B = 0;
                o_reg_W = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB];
                o_flag_branch = 0;
                o_immediate = i_instruction [CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB - 1 : CANT_BITS_ID_LSB];
            end
        4://SLLV
            begin
                o_reg_A = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 3 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB];;
                o_reg_B = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                 CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS - 1];
                o_reg_W = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB];
                o_flag_branch = 0;
                o_immediate = 0;
            end
        6://SRLV
            begin
                o_reg_A = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 3 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB];;
                o_reg_B = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                 CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS - 1];
                o_reg_W = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB];
                o_flag_branch = 0;
                o_immediate = 0;
            end
        7://SRAV
            begin
                o_reg_A = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 3 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB];;
                o_reg_B = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                 CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS - 1];
                o_reg_W = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB];
                o_flag_branch = 0;
                o_immediate = 0;
            end
        33://ADDU
            begin
                o_reg_A = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 3 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB];;
                o_reg_B = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                 CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS - 1];
                o_reg_W = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB];
                o_flag_branch = 0;
                o_immediate = 0;
            end
        35://SUBU
            begin
                o_reg_A = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 3 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB];;
                o_reg_B = i_instruction [CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - 1 :
                 CANT_BITS_INSTRUCCION - CANT_BITS_ESPECIAL - CANT_BITS_ADDRESS_REGISTROS - 1];
                o_reg_W = i_instruction [CANT_BITS_ADDRESS_REGISTROS * 2 + CANT_BITS_ID_LSB - 1: CANT_BITS_ADDRESS_REGISTROS + CANT_BITS_ID_LSB];
                o_flag_branch = 0;
                o_immediate = 0;
            end
        default:
            begin
                o_reg_A = 0;
                o_reg_B = 0;
                o_reg_W = 0;
                o_flag_branch = 0;
                o_immediate = 0;
            end
    endcase
end

endmodule
