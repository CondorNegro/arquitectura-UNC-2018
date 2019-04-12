`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Adder signed.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////////////////////


module adder_signed
   #(
       parameter INPUT_OUTPUT_LENGTH = 11
   )
   (
       input [INPUT_OUTPUT_LENGTH - 1 : 0] i_data_A,
       input signed [INPUT_OUTPUT_LENGTH - 1 : 0] i_data_B,
       output reg [INPUT_OUTPUT_LENGTH - 1 : 0] o_result
   );

  always@(*) begin
    o_result = i_data_A + i_data_B;
  end

endmodule
