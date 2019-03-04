`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Mux general.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////////////////////


module mux
   #(
       parameter INPUT_OUTPUT_LENGTH = 11
   )
   (
       input [INPUT_OUTPUT_LENGTH - 1 : 0] i_data_A,
       input [INPUT_OUTPUT_LENGTH - 1 : 0] i_data_B,
       input i_selector,
       output [INPUT_OUTPUT_LENGTH - 1 : 0] o_result     
   );

  assign o_result = (i_selector) ? i_data_B : i_data_A;

endmodule
