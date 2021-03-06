`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Contador de ciclos.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////////////////////


module contador_ciclos
   #(
       parameter CONTADOR_LENGTH = 11
   )
   (
       input i_clock,
       input i_soft_reset,
       input i_enable,
       output reg [CONTADOR_LENGTH - 1 : 0] o_cuenta
   );



always@( posedge i_clock) begin
    // Se resetean los registros.
   if (~ i_soft_reset) begin
       o_cuenta <= 0;
   end
   else if (i_enable == 1'b1) begin
       o_cuenta <= o_cuenta + 1;
   end
   else begin
       o_cuenta <= o_cuenta;
   end
end

endmodule
