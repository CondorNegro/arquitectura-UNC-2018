`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Práctico N° 1. ALU.
// TOP.
// Integrantes: Kleiner Matías, López Gastón.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Año 2018.
//////////////////////////////////////////////////////////////////////////////////


`define BUS_DATOS           4   // Tamaño del bus de entrada. (Por ejemplo, cantidad de switches).
`define BUS_SALIDA          4   // Tamaño del bus de salida. (Por ejemplo, cantidad de leds).
`define CANT_BOTONES_ALU    4   // Cantidad de botones.
`define CANT_BIT_OPCODE    4   // Número de bits del código de operación de la ALU.

module top_arquitectura(
  i_clock, 
  i_reset, 
  i_switches,
  i_botones,
  o_leds 
  );

// Parámetros
parameter BUS_DATOS = `BUS_DATOS;
parameter BUS_SALIDA = `BUS_SALIDA;
parameter CANT_BOTONES_ALU = `CANT_BOTONES_ALU;
parameter CANT_BIT_OPCODE = `CANT_BIT_OPCODE;

// Entradas - Salidas
input i_clock;                                  // Clock.
input i_reset;                                  // Reset.
input [BUS_DATOS - 1 : 0] i_switches;           // Switches.
input [CANT_BOTONES_ALU - 1 : 0] i_botones;     // Botones.
output [BUS_SALIDA - 1 : 0] o_leds;             // Leds.

// Registros.
reg [BUS_DATOS - 1 : 0] reg_dato_A;
reg [BUS_DATOS - 1 : 0] reg_dato_B;
reg [CANT_BIT_OPCODE - 1 : 0] reg_opcode;

// Wires.
wire [BUS_DATOS - 1 : 0] wire_operando_1;
wire [BUS_DATOS - 1 : 0] wire_operando_2;
wire [CANT_BIT_OPCODE - 1 : 0] wire_opcode;

// Asignación.
assign wire_operando_1 = reg_dato_A; 
assign wire_operando_2 = reg_dato_B;
assign wire_opcode = reg_opcode;

// Módulo ALU.
alu
    #(
         .CANT_BUS_ENTRADA (BUS_DATOS),
         .CANT_BUS_SALIDA (BUS_SALIDA),
         .CANT_BITS_OPCODE (CANT_BIT_OPCODE)
     ) 
   u_alu1    // Una sola instancia de este módulo
   (
   .i_operando_1 (wire_operando_1),
   .i_operando_2 (wire_operando_2),
   .i_opcode (wire_opcode),
   .o_resultado (o_leds)
   );

always@( posedge i_clock) begin
     // Se resetean los registros.
     if (i_reset) begin
        reg_dato_A <= 0;
        reg_dato_B <= 0;
        reg_opcode <= 0;
     end 
     
     else begin
        // Si se presiona el botón 1
        if (i_botones == 3'b001) begin
            reg_dato_A <= i_switches;
            reg_dato_B <= reg_dato_B;
            reg_opcode <= reg_opcode;
        end
        // Si se presiona el botón 2
        else  if (i_botones == 3'b010) begin
           reg_dato_A <= reg_dato_A;
           reg_dato_B <= i_switches;
           reg_opcode <= reg_opcode;
        end
        // Si se presiona el botón 3
        else  if (i_botones == 3'b100) begin
           reg_dato_A <= reg_dato_A;
           reg_dato_B <= reg_dato_B;
           reg_opcode <= i_switches;
        end        
     end   
end

endmodule
