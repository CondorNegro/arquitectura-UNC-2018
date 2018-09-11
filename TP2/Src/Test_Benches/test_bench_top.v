 `timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 1. ALU.
// Test bench del modulo configurador.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////

`define CANT_DATOS_ENTRADA      4   // Tamanio del bus de entrada. (Por ejemplo, cantidad de switches).
`define CANT_BOTONES_OPCODE     4   // Cantidad de botones.
`define CANT_BITS_OPCODE_ALU    4   // Cantidad de bits del codigo de operacion.

module test_bench_configurador();
		
	// Parametros
    parameter CANT_DATOS_ENTRADA = `CANT_DATOS_ENTRADA;
    parameter CANT_BOTONES_OPCODE = `CANT_BOTONES_OPCODE;
    parameter CANT_BITS_OPCODE_ALU = `CANT_BITS_OPCODE_ALU;
	
	//Todo puerto de salida del modulo es un cable.
	//Todo puerto de estimulo o generacion de entrada es un registro.
	
	// Entradas.
    reg clock;                                  // Clock.
    reg hard_reset;                             // Reset.
    reg [CANT_DATOS_ENTRADA - 1 : 0] switches;           // Switches.
    reg [CANT_BOTONES_OPCODE - 1 : 0] botones;     // Botones.
    
    // Salidas.
    wire [CANT_DATOS_ENTRADA - 1 : 0] dato_A;
    wire [CANT_DATOS_ENTRADA - 1 : 0] dato_B;
    wire [CANT_BITS_OPCODE_ALU - 1 : 0] opcode;
    
	
	
	initial	begin
		clock = 1'b0;
		hard_reset = 1'b0; // Reset en 0. (Normal cerrado el boton del reset).
		switches = 4'b0000; 
		botones = 4'b0000;
		#10 hard_reset = 1'b1; // Desactivo la accion del reset.
		
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
		#100 hard_reset = 1'b0; // Reset.
		#10 hard_reset = 1'b1; // Desactivo el reset.
		
		
		#10000 $finish;
	end
	
	always #2.5 clock=~clock;  // Simulacion de clock.



//Modulo para pasarle los estimulos del banco de pruebas.
configurador
    #(
         .CANT_DATOS_ENTRADA (CANT_DATOS_ENTRADA),
         .CANT_BOTONES_OPCODE (CANT_BOTONES_OPCODE),
         .CANT_BITS_OPCODE_ALU (CANT_BITS_OPCODE_ALU)
     ) 
   u_configurador_1    // Una sola instancia de este modulo.
  (
      .i_clock (clock),
      .i_reset (hard_reset),
      .i_switches (switches),
      .i_botones (botones),
      .o_reg_dato_A (dato_A),
      .o_reg_dato_B (dato_B),
      .o_reg_opcode (opcode)
      );
   
endmodule

