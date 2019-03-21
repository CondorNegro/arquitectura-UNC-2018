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
       parameter CANT_BITS_IMMEDIATE = 16
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

       output o_led
   );



    //  The following function calculates the address width based on specified RAM depth
    function integer clogb2;
        input integer depth;
            for (clogb2=0; depth>0; clogb2=clogb2+1)
                depth = depth >> 1;
    endfunction

    
decoder
    #(
        .CANT_BITS_INSTRUCCION (LENGTH_INSTRUCTION)
    )
    (
        .i_instruction (i_instruction),
        .o_reg_A (),
        .o_reg_B (),
        .o_reg_W (),
        .o_flag_branch (),
        .o_immediate ()
    )

adder
   #(
       .INPUT_OUTPUT_LENGTH (CANT_BITS_ADDR)
   )
   u_adder_1
   (
       .i_data_A (i_out_adder_pc),
       .i_data_B (),
       .o_result (o_branch_dir)
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
        .i_reg_A (),
        .i_reg_B (),
        .i_reg_Write (i_reg_write),
        .i_data_write (i_data_write),
        .i_control_write (i_control_write_reg),
        .o_data_A (o_data_A),
        .o_data_B (o_data_B),
        .o_led (o_led)
    );

control 
    #(

    )
    u_control_1
    (

    );


  

endmodule
