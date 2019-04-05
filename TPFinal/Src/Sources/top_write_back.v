`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// TOP de la etapa de write back.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////////////////////


module top_write_back
   #(
       
       parameter CANT_REGISTROS= 32,
       parameter CANT_BITS_REGISTROS = 32
       
   )
   (
       
       input [clogb2 (CANT_REGISTROS - 1) - 1 : 0] i_registro_destino,
       
       input [CANT_BITS_REGISTROS - 1 : 0] i_data_mem,
       input [CANT_BITS_REGISTROS - 1 : 0] i_data_alu,

       input i_RegWrite,
       input i_MemtoReg,
       

       output [clogb2 (CANT_REGISTROS - 1) - 1 : 0] o_registro_destino,
       output o_RegWrite,
       output [CANT_BITS_REGISTROS - 1 : 0] o_data_write,


       output o_led
   );



    //  The following function calculates the address width based on specified RAM depth
    function integer clogb2;
        input integer depth;
            for (clogb2=0; depth>0; clogb2=clogb2+1)
                depth = depth >> 1;
    endfunction


    assign o_registro_destino = i_registro_destino;
    assign o_RegWrite = i_RegWrite;




mux
   #(
       .INPUT_OUTPUT_LENGTH (CANT_BITS_REGISTROS)
    )
    u_mux_1
   (
       .i_data_A (i_data_mem),
       .i_data_B (i_data_alu),
       .i_selector (i_MemtoReg),
       .o_result (o_data_write)
    );



  

endmodule
