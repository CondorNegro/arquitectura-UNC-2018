`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Mux forward.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////////////////////


module mux_forward
   #(
       parameter INPUT_OUTPUT_LENGTH = 32
   )
   (
       input [INPUT_OUTPUT_LENGTH - 1 : 0] i_data_normal,
       input [INPUT_OUTPUT_LENGTH - 1 : 0] i_data_forward_mem,
       input [INPUT_OUTPUT_LENGTH - 1 : 0] i_data_forward_wb,
       input [1 : 0] i_selector,
       output reg [INPUT_OUTPUT_LENGTH - 1 : 0] o_result     
   );

  always@(*) begin
        case (i_selector)
            0 : begin
              o_result = i_data_normal;
            end
            1 : begin
              o_result = i_data_forward_wb;
            end
            2 : begin
              o_result = i_data_forward_mem;
            end
            default : begin
              o_result = i_data_normal;
            end
        endcase
  end

endmodule