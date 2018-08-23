 
`timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Pr�ctico N� 1. ALU.
// Test bench del TOP.
// Integrantes: Kleiner Mat�as, L�pez Gast�n.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// A�o 2018.
//////////////////////////////////////////////////////////////////////////////////

`define BUS_DATOS           4   // Tama�o del bus de entrada. (Por ejemplo, cantidad de switches).
`define BUS_SALIDA          4   // Tama�o del bus de salida. (Por ejemplo, cantidad de leds).
`define CANT_BOTONES_ALU    4   // Cantidad de botones.
`define CANT_BITS_OPCODE     4

module test_bench_top();
	
	
	// Par�metros
    parameter BUS_DATOS = `BUS_DATOS;
    parameter BUS_SALIDA = `BUS_SALIDA;
    parameter CANT_BOTONES_ALU = `CANT_BOTONES_ALU;
    parameter CANT_BITS_OPCODE = `CANT_BITS_OPCODE;
	
	//Todo puerto de salida del m�dulo es un cable.
	//Todo puerto de est�mulo o generaci�n de entrada es un registro.
	
	// Entradas - Salidas
    reg clock;                                  // Clock.
    reg hard_reset;                             // Reset.
    reg [BUS_DATOS - 1 : 0] switches;           // Switches.
    reg [CANT_BOTONES_ALU - 1 : 0] botones;     // Botones.
    wire [BUS_SALIDA - 1 : 0] leds;             // Leds.
	
	
	initial	begin
		clock = 1'b0;
		hard_reset = 1'b1; // Reset en 1.
		switches = 4'b0000; 
		botones = 4'b0000;
		#10 hard_reset = 1'b0; // Bajo el reset.
		
		// Test 1: cargar primer operando.
		#10 botones[0] = 1'b1;
		#10 switches = 4'b0101;
		#10 botones[0] = 1'b0;
		
		// Test 2: cargar operacion.
		#10 botones[1] = 1'b1;
        #10 switches = 4'b1000; //ADD
        #10 botones[1] = 1'b0;
		
		// Test 3: cargar tercer operando.
		#10 botones[2] = 1'b1;
        #10 switches = 4'b0101;
        #10 botones[2] = 1'b0;
		
		// Test 13: Prueba reset.
		#100 hard_reset = 1'b1; // Reset.
		#10 hard_reset = 1'b0; // Bajo el reset.
		
		
		#1000000000 $finish;
	end
	
	always #2.5 clock=~clock;  // Simulaci�n de clock.



//M�dulo para pasarle los est�mulos del banco de pruebas.
top_arquitectura
    #(
         .BUS_DATOS (BUS_DATOS),
         .BUS_SALIDA (BUS_SALIDA),
         .CANT_BOTONES_ALU (CANT_BOTONES_ALU),
         .CANT_BIT_OPCODE (CANT_BITS_OPCODE)
     ) 
   u_top_arquitectura_1    // Una sola instancia de este m�dulo
   (
   .i_clock (clock),
   .i_reset (hard_reset),
   .i_switches (switches),
   .i_botones (botones),
   .o_leds (leds)
   );
   
endmodule

