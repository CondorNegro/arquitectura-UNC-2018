`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 3. BIP I.
// Address Calculator.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////////////////////

module address_calculator
#(
  parameter PC_CANT_BITS = 11,  // Cantidad de bits del PC.
  parameter SUM_DIR = 1         // Cantidad a sumar al PC para obtener la direccion siguiente.
)

(
  input i_clock,
  input i_reset,
  input i_wrPC,
  output [PC_CANT_BITS-1:0] o_addr
);

  reg [PC_CANT_BITS-1:0] reg_PC;




  always @(negedge i_clock) begin
    if (~i_reset) begin
      reg_PC <= 0;

    end
    else begin

      if (i_wrPC) begin  // Deteccion por flanco
        reg_PC <= reg_PC + SUM_DIR;
      end
      else begin
        reg_PC <= reg_PC;
      end
    end
 end
    assign o_addr = reg_PC;

endmodule
