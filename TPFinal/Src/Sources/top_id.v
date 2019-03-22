`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// TOP del instruction decode.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////////////////////


module top_id
   #(
       parameter LENGTH_INSTRUCTION = 32,
       parameter CANT_REGISTROS= 32,
       parameter CANT_BITS_ADDR = 11,
       parameter CANT_BITS_REGISTROS = 32,
       parameter CANT_BITS_IMMEDIATE = 16,
       parameter CANT_BITS_ESPECIAL = 6,
       parameter CANT_BITS_CEROS = 5,
       parameter CANT_BITS_ID_LSB = 6,
       parameter CANT_BITS_INSTRUCTION_INDEX_BRANCH = 26,
       parameter CANT_BITS_FLAG_BRANCH = 3,
       parameter CANT_BITS_ALU_OP = 2  
   )
   (
       input i_clock,
       input i_soft_reset,
       
       input [LENGTH_INSTRUCTION - 1 : 0] i_instruction,
       input [CANT_BITS_ADDR - 1 : 0] i_out_adder_pc,
      
       
       input i_control_write_reg,
       input [clogb2 (CANT_REGISTROS - 1) - 1 : 0] i_reg_write,
       input [CANT_BITS_REGISTROS - 1 : 0] i_data_write,



       output [CANT_BITS_ADDR - 1 : 0] o_branch_dir,
       output o_branch_control,

       output [CANT_BITS_REGISTROS - 1 : 0] o_data_A,
       output [CANT_BITS_REGISTROS - 1 : 0] o_data_B,

       output [CANT_BITS_IMMEDIATE - 1 : 0] o_extension_signo_constante,
       output [clogb2 (CANT_REGISTROS - 1) - 1 : 0] o_reg_rs,
       output [clogb2 (CANT_REGISTROS - 1) - 1 : 0] o_reg_rt,
       output [clogb2 (CANT_REGISTROS - 1) - 1 : 0] o_reg_rd,
       
       // Control

       output o_RegDst,
       output o_RegWrite,
       output o_ALUSrc,
       output [CANT_BITS_ALU_OP - 1 : 0] o_ALUOp,
       output o_MemRead,
       output o_MemWrite,
       output o_MemtoReg,
       output o_flag_branch,   

       output o_led
   );



    //  The following function calculates the address width based on specified RAM depth
    function integer clogb2;
        input integer depth;
            for (clogb2=0; depth>0; clogb2=clogb2+1)
                depth = depth >> 1;
    endfunction


    wire [clogb2 (CANT_REGISTROS - 1) - 1 : 0] wire_output_reg_A_decoder_TO_reg_A_register_file;
    wire [clogb2 (CANT_REGISTROS - 1) - 1 : 0] wire_output_reg_B_decoder_TO_reg_B_register_file;
    
    wire [CANT_BITS_IMMEDIATE - 1 : 0] wire_output_immediate_decoder_TO_extension_signo;
  
    assign o_extension_signo_constante = {(CANT_BITS_REGISTROS - CANT_BITS_IMMEDIATE) {wire_output_immediate_decoder_TO_extension_signo[CANT_BITS_IMMEDIATE - 1]},wire_output_immediate_decoder_TO_extension_signo}; // Extension de signo.

    wire [CANT_BITS_FLAG_BRANCH - 1 : 0] wire_output_flag_branch_decoder_TO_flag_branch_branch_address_calculator;
    wire [CANT_BITS_INSTRUCTION_INDEX_BRANCH - 1 : 0] wire_output_instruction_index_branch_decoder_TO_instruction_index_branch_branch_address_calculator;
    
    
    assign o_flag_branch = wire_output_flag_branch_decoder_TO_flag_branch_branch_address_calculator;


decoder
    #(
        .CANT_BITS_INSTRUCCION (LENGTH_INSTRUCTION),
        .CANT_BITS_ADDRESS_REGISTROS (clogb2 (CANT_REGISTROS - 1)),
        .CANT_BITS_IMMEDIATE (CANT_BITS_IMMEDIATE),
        .CANT_BITS_ESPECIAL (CANT_BITS_ESPECIAL),
        .CANT_BITS_CEROS (CANT_BITS_CEROS),
        .CANT_BITS_ID_LSB (CANT_BITS_ID_LSB),
        .CANT_BITS_INSTRUCTION_INDEX_BRANCH (CANT_BITS_INSTRUCTION_INDEX_BRANCH),
        .CANT_BITS_FLAG_BRANCH (CANT_BITS_FLAG_BRANCH)

    )
    (
        .i_instruction (i_instruction),
        .o_reg_A (wire_output_reg_A_decoder_TO_reg_A_register_file),
        .o_reg_B (wire_output_reg_B_decoder_TO_reg_B_register_file),
        .o_reg_W (o_reg_rd),
        .o_flag_branch (wire_output_flag_branch_decoder_TO_flag_branch_branch_address_calculator),
        .o_immediate (wire_output_immediate_decoder_TO_extension_signo),
        .o_instruction_index_branch (wire_output_instruction_index_branch_decoder_TO_instruction_index_branch_branch_address_calculator)
    );


branch_address_calculator 
    #(
        .CANT_BITS_INSTRUCTION_INDEX_BRANCH (CANT_BITS_INSTRUCTION_INDEX_BRANCH),
        .CANT_BITS_FLAG_BRANCH (CANT_BITS_FLAG_BRANCH),
        .CANT_BITS_ADDR (CANT_BITS_ADDR),
        .CANT_BITS_IMMEDIATE (CANT_BITS_IMMEDIATE),
        .CANT_BITS_REGISTROS (CANT_BITS_REGISTROS)
    )
    (
        .i_flag_branch (wire_output_flag_branch_decoder_TO_flag_branch_branch_address_calculator),
        .i_adder_pc (i_out_adder_pc),
        .i_dato_reg_A (o_data_A),
        .i_dato_reg_B (o_data_B),
        .i_immediate_address (o_extension_signo_constante),
        .i_instruction_index_branch (wire_output_instruction_index_branch_decoder_TO_instruction_index_branch_branch_address_calculator),
        .o_branch_control (o_branch_control),
        .o_branch_dir (o_branch_dir)
    );


register_file
    #(
        .CANTIDAD_REGISTROS (CANT_REGISTROS),
        .CANTIDAD_BITS_REGISTROS (CANT_BITS_REGISTROS),
        .CANTIDAD_BITS_ADDRESS_REGISTROS (clogb2 (CANT_REGISTROS - 1))
    )
    u_register_file_1
    (
        .i_clock (i_clock),
        .i_soft_reset (i_soft_reset),
        .i_reg_A (wire_output_reg_A_decoder_TO_reg_A_register_file),
        .i_reg_B (wire_output_reg_B_decoder_TO_reg_B_register_file),
        .i_reg_Write (i_reg_write),
        .i_data_write (i_data_write),
        .i_control_write (i_control_write_reg),
        .o_data_A (o_data_A),
        .o_data_B (o_data_B),
        .o_led (o_led)
    );

control 
    #(
        .CANT_BITS_INSTRUCTION (LENGTH_INSTRUCTION),
        .CANT_BITS_FLAG_BRANCH (CANT_BITS_FLAG_BRANCH),
        .CANT_BITS_ALU_OP (CANT_BITS_ALU_OP),
        .CANT_BITS_ESPECIAL (CANT_BITS_ESPECIAL),
        .CANT_BITS_ID_LSB (CANT_BITS_ID_LSB)

    )
    u_control_1
    (
        .i_clock (i_clock),
        .i_soft_reset (i_soft_reset),
        .i_instruction (i_instruction),
        .o_RegDst (o_RegDst),
        .o_RegWrite (o_RegWrite),
        .o_ALUSrc (o_ALUSrc),
        .o_ALUOp (o_ALUOp),
        .o_MemRead (o_MemRead),
        .o_MemWrite (o_MemWrite),
        .o_MemtoReg (o_MemtoReg)
    );



  

endmodule
