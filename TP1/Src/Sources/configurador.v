 `timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Pr�ctico N� 1. ALU.
// ALU.
// Integrantes: Kleiner Mat�as, L�pez Gast�n.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// A�o 2018.
//////////////////////////////////////////////////////////////////////////////////

// Constantes.
`define CANT_BUS_ENTRADA 6
`define CANT_BUS_SALIDA 6
`define CANT_BITS_OPCODE 4
`define CANT_BOTONES_ALU    4   // Cantidad de botones.

module configurador(
    i_clock, 
    i_reset,
    i_switches,
    i_botones,
    o_reg_dato_A,
    o_reg_dato_B,
    o_reg_opcode
    );

// Par�metros.
parameter CANT_BUS_ENTRADA = `CANT_BUS_ENTRADA;
parameter CANT_BUS_SALIDA = `CANT_BUS_SALIDA;
parameter CANT_BITS_OPCODE = `CANT_BITS_OPCODE;
parameter CANT_BOTONES_ALU = `CANT_BOTONES_ALU;


// Entradas - Salidas.

input i_clock;     
input i_reset; 
input [CANT_BUS_ENTRADA - 1 : 0] i_switches; 
input [CANT_BOTONES_ALU - 1 : 0] i_botones; 
output [CANT_BUS_ENTRADA - 1 : 0] o_reg_dato_A;             // C�digo de operaci�n.
output [CANT_BUS_ENTRADA - 1 : 0] o_reg_dato_B; 
output [CANT_BITS_OPCODE - 1 : 0] o_reg_opcode;                



// Registros.
reg [CANT_BUS_ENTRADA - 1 : 0] reg_dato_A;
reg [CANT_BUS_ENTRADA - 1 : 0] reg_dato_B;
reg [CANT_BITS_OPCODE - 1 : 0] reg_opcode;

always@( posedge i_clock) begin
     // Se resetean los registros.
     if (i_reset) begin
        reg_dato_A <= 0;
        reg_dato_B <= 0;
        reg_opcode <= 0;
     end 
     
     else begin
        // Si se presiona el botón 1
        if (i_botones == 1) begin
            reg_dato_A <= i_switches;
            reg_dato_B <= reg_dato_B;
            reg_opcode <= reg_opcode;
        end
        // Si se presiona el botón 2
        else  if (i_botones == 2) begin
           reg_dato_A <= reg_dato_A;
           reg_dato_B <= i_switches;
           reg_opcode <= reg_opcode;
        end
        // Si se presiona el botón 3
        else  if (i_botones == 4) begin
           reg_dato_A <= reg_dato_A;
           reg_dato_B <= reg_dato_B;
           reg_opcode <= i_switches;
        end
        else begin
            reg_dato_A <= reg_dato_A;
            reg_dato_B <= reg_dato_B;
            reg_opcode <= reg_opcode;
        end        
     end   
end

// Asignaci�n.
assign o_reg_dato_A = reg_dato_A;
assign o_reg_dato_B = reg_dato_B;
assign o_reg_opcode = reg_opcode;

endmodule


