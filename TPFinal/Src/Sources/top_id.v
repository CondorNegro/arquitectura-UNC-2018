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
       parameter CANT_BITS_ALU_OP = 2,
       parameter CANT_BITS_ALU_CONTROL = 4  
   )
   (
       input i_clock,
       input i_soft_reset,
       
       input [LENGTH_INSTRUCTION - 1 : 0] i_instruction,
       input [CANT_BITS_ADDR - 1 : 0] i_out_adder_pc,
      
       
       input i_control_write_reg,
       input [clogb2 (CANT_REGISTROS - 1) - 1 : 0] i_reg_write,
       input [CANT_BITS_REGISTROS - 1 : 0] i_data_write,

       input i_enable_pipeline,
       input i_enable_etapa, 

       output  [CANT_BITS_ADDR - 1 : 0] o_branch_dir,
       output  o_branch_control,

       output  reg [CANT_BITS_ADDR - 1 : 0] o_branch_dir_to_database, //Para guardar coherencia de datos almacenados en database.
       output  reg o_branch_control_to_database, //Para guardar coherencia de datos almacenados en database.

       output reg [CANT_BITS_REGISTROS - 1 : 0] o_data_A,
       output reg [CANT_BITS_REGISTROS - 1 : 0] o_data_B,

       output reg [CANT_BITS_REGISTROS - 1 : 0] o_extension_signo_constante,
       output reg [clogb2 (CANT_REGISTROS - 1) - 1 : 0] o_reg_rs,
       output reg [clogb2 (CANT_REGISTROS - 1) - 1 : 0] o_reg_rt,
       output reg [clogb2 (CANT_REGISTROS - 1) - 1 : 0] o_reg_rd,
       
       // Control

       output reg o_RegDst,
       output reg o_RegWrite,
       output reg o_ALUSrc,
       output reg [CANT_BITS_ALU_OP - 1 : 0] o_ALUOp,
       output reg o_MemRead,
       output reg o_MemWrite,
       output reg o_MemtoReg,
       output reg [CANT_BITS_ALU_CONTROL - 1 : 0] o_ALUCtrl,   

       output o_led
   );



    //  The following function calculates the address width based on specified RAM depth
    function integer clogb2;
        input integer depth;
            for (clogb2=0; depth>0; clogb2=clogb2+1)
                depth = depth >> 1;
    endfunction


    wire [CANT_BITS_FLAG_BRANCH - 1 : 0] wire_output_flag_branch_decoder_TO_flag_branch_branch_address_calculator;
    wire [CANT_BITS_INSTRUCTION_INDEX_BRANCH - 1 : 0] wire_output_instruction_index_branch_decoder_TO_instruction_index_branch_branch_address_calculator;
    


    wire [CANT_BITS_REGISTROS - 1 : 0] wire_o_data_A;
    wire [CANT_BITS_REGISTROS - 1 : 0] wire_o_data_B;
    wire [CANT_BITS_REGISTROS - 1 : 0] wire_o_extension_signo_constante;
    wire [clogb2 (CANT_REGISTROS - 1) - 1 : 0] wire_o_reg_rs;
    wire [clogb2 (CANT_REGISTROS - 1) - 1 : 0] wire_o_reg_rt;
    wire [clogb2 (CANT_REGISTROS - 1) - 1 : 0] wire_o_reg_rd;
    wire wire_o_RegDst;
    wire wire_o_RegWrite;
    wire wire_o_ALUSrc;
    wire [CANT_BITS_ALU_OP - 1 : 0] wire_o_ALUOp;
    wire wire_o_MemRead;
    wire wire_o_MemWrite;
    wire wire_o_MemtoReg;
    wire [CANT_BITS_ALU_CONTROL - 1 : 0] wire_o_ALUCtrl;



    wire [clogb2 (CANT_REGISTROS - 1) - 1 : 0] wire_output_reg_A_decoder_TO_reg_A_register_file;
    assign wire_o_reg_rs = wire_output_reg_A_decoder_TO_reg_A_register_file;
    
    wire [clogb2 (CANT_REGISTROS - 1) - 1 : 0] wire_output_reg_B_decoder_TO_reg_B_register_file;
    assign wire_o_reg_rt = wire_output_reg_B_decoder_TO_reg_B_register_file;
    
    wire [CANT_BITS_IMMEDIATE - 1 : 0] wire_output_immediate_decoder_TO_extension_signo;
  
    assign wire_o_extension_signo_constante = {{(CANT_BITS_REGISTROS - CANT_BITS_IMMEDIATE) {wire_output_immediate_decoder_TO_extension_signo[CANT_BITS_IMMEDIATE - 1]}},wire_output_immediate_decoder_TO_extension_signo}; // Extension de signo.



    
    always@(negedge i_clock) begin
      if (~i_soft_reset) begin
            o_data_A <= 0;
            o_data_B <= 0;
            o_extension_signo_constante <= 0;
            o_reg_rs <= 0;
            o_reg_rt <= 0;
            o_reg_rd <= 0;       
            o_RegDst <= 0;
            o_RegWrite <= 0;
            o_ALUSrc <= 0;
            o_ALUOp <= 0;
            o_MemRead <= 0;
            o_MemWrite <= 0;
            o_MemtoReg <= 0;
            o_ALUCtrl <= 0;
            o_branch_dir_to_database <= 0;
            o_branch_control_to_database <= 0;   
      end
      else begin
            if (i_enable_pipeline) begin
                o_data_A <= wire_o_data_A;
                o_data_B <= wire_o_data_B;
                o_extension_signo_constante <= wire_o_extension_signo_constante;
                o_reg_rs <= wire_o_reg_rs;
                o_reg_rt <= wire_o_reg_rt;
                o_reg_rd <= wire_o_reg_rd;       
                o_RegDst <= wire_o_RegDst;
                o_RegWrite <= wire_o_RegWrite;
                o_ALUSrc <= wire_o_ALUSrc;
                o_ALUOp <= wire_o_ALUOp;
                o_MemRead <= wire_o_MemRead;
                o_MemWrite <= wire_o_MemWrite;
                o_MemtoReg <= wire_o_MemtoReg;
                o_ALUCtrl <= wire_o_ALUCtrl;
                o_branch_dir_to_database <= o_branch_dir;
                o_branch_control_to_database <= o_branch_control;  
            end
            else begin
                o_data_A <= o_data_A;
                o_data_B <= o_data_B;
                o_extension_signo_constante <= o_extension_signo_constante;
                o_reg_rs <= o_reg_rs;
                o_reg_rt <= o_reg_rt;
                o_reg_rd <= o_reg_rd;       
                o_RegDst <= o_RegDst;
                o_RegWrite <= o_RegWrite;
                o_ALUSrc <= o_ALUSrc;
                o_ALUOp <= o_ALUOp;
                o_MemRead <= o_MemRead;
                o_MemWrite <= o_MemWrite;
                o_MemtoReg <= o_MemtoReg;
                o_ALUCtrl <= o_ALUCtrl;
                o_branch_dir_to_database <= o_branch_dir_to_database;
                o_branch_control_to_database <= o_branch_control_to_database;  
            end 
    end
    end

   


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
    u_decoder_1
    (
        .i_instruction (i_instruction),
        .i_enable_etapa (i_enable_etapa),
        .o_reg_A (wire_output_reg_A_decoder_TO_reg_A_register_file),
        .o_reg_B (wire_output_reg_B_decoder_TO_reg_B_register_file),
        .o_reg_W (wire_o_reg_rd),
        .o_flag_branch (wire_output_flag_branch_decoder_TO_flag_branch_branch_address_calculator),
        .o_immediate (wire_output_immediate_decoder_TO_extension_signo),
        .o_instruction_index_branch (wire_output_instruction_index_branch_decoder_TO_instruction_index_branch_branch_address_calculator)
    );


branch_address_calculator 
    #(
        .CANT_BITS_INSTRUCTION_INDEX_BRANCH (CANT_BITS_INSTRUCTION_INDEX_BRANCH),
        .CANT_BITS_FLAG_BRANCH (CANT_BITS_FLAG_BRANCH),
        .CANT_BITS_ADDR (CANT_BITS_ADDR),
        .CANT_BITS_REGISTROS (CANT_BITS_REGISTROS)
    )
    u_branch_address_calculator_1
    (
        .i_flag_branch (wire_output_flag_branch_decoder_TO_flag_branch_branch_address_calculator),
        .i_adder_pc (i_out_adder_pc),
        .i_dato_reg_A (wire_o_data_A),
        .i_dato_reg_B (wire_o_data_B),
        .i_immediate_address (wire_o_extension_signo_constante),
        .i_instruction_index_branch (wire_output_instruction_index_branch_decoder_TO_instruction_index_branch_branch_address_calculator),
        .i_enable_etapa (i_enable_etapa),
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
        .o_data_A (wire_o_data_A),
        .o_data_B (wire_o_data_B),
        .o_led (o_led)
    );

control 
    #(
        .CANT_BITS_INSTRUCTION (LENGTH_INSTRUCTION),
        .CANT_BITS_FLAG_BRANCH (CANT_BITS_FLAG_BRANCH),
        .CANT_BITS_ALU_OP (CANT_BITS_ALU_OP),
        .CANT_BITS_ESPECIAL (CANT_BITS_ESPECIAL),
        .CANT_BITS_ID_LSB (CANT_BITS_ID_LSB),
        .CANT_BITS_ALU_CONTROL (CANT_BITS_ALU_CONTROL)

    )
    u_control_1
    (
        .i_clock (i_clock),
        .i_soft_reset (i_soft_reset),
        .i_instruction (i_instruction),
        .i_enable_etapa (i_enable_etapa),
        .o_RegDst (wire_o_RegDst),
        .o_RegWrite (wire_o_RegWrite),
        .o_ALUSrc (wire_o_ALUSrc),
        .o_ALUOp (wire_o_ALUOp),
        .o_ALUCtrl (wire_o_ALUCtrl),
        .o_MemRead (wire_o_MemRead),
        .o_MemWrite (wire_o_MemWrite),
        .o_MemtoReg (wire_o_MemtoReg)
    );



  

endmodule
