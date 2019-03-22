`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Branch address calculator.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////////////////////


module branch_address_calculator
   #(
       
       parameter CANT_BITS_ADDR = 11,
       parameter CANT_BITS_IMMEDIATE = 16,
       parameter CANT_BITS_INSTRUCTION_INDEX_BRANCH = 26,
       parameter CANT_BITS_FLAG_BRANCH = 3  
   )
   (
       input [] i_flag_branch,
       input [] i_adder_pc,
       input [] i_immediate_address,
       input [] i_instruction_index_branch,
       input o_branch_control,
       input [] o_branch_dir,
      
   );



    wire [] wire_resultado_sumador;


adder
   #(
       .INPUT_OUTPUT_LENGTH (CANT_BITS_ADDR)
   )
   u_adder_1
   (
       .i_data_A (i_adder_pc),
       .i_data_B (i_immediate_address[]), //No se debe realizar un desplazamiento de dos (<<2) porque el PC suma de a uno.
       .o_result (wire_resultado_sumador)
   );




endmodule
