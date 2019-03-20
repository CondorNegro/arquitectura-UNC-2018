`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Contador de programa.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////////////////////


module pc
   #(
       parameter CONTADOR_LENGTH = 11,
       parameter INSTRUCTION_LENGTH = 32
   )
   (
       input i_clock,
       input i_soft_reset,
       input i_enable,
       input [CONTADOR_LENGTH - 1 : 0] i_direccion,
       output reg [CONTADOR_LENGTH - 1 : 0] o_direccion
   );



always@( posedge i_clock) begin
    // Se resetean los registros.
   if (~ i_soft_reset) begin
       o_direccion <= 0;
   end
   else if (i_enable == 1) begin
       o_direccion <= i_direccion;
   end
   else begin
        o_direccion <= o_direccion;
   end
end

endmodule
