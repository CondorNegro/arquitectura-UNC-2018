 `timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 2. UART.
// Test bench del modulo interface_circuit.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////

// Constantes.
`define CANT_DATOS_ENTRADA_ALU      8       // Tamanio del bus de entrada de la ALU.
`define CANT_BITS_OPCODE_ALU        8       // Numero de bits del codigo de operacion de la ALU.
`define CANT_DATOS_SALIDA_ALU       8       // Tamanio del bus de salida de la ALU.
`define WIDTH_WORD                  8       // Tamanio de palabra de la trama UART.

module test_bench_interface_circuit();
		
	// Parametros
    parameter CANT_DATOS_ENTRADA_ALU = `CANT_DATOS_ENTRADA_ALU;
    parameter CANT_BITS_OPCODE_ALU = `CANT_BITS_OPCODE_ALU;
	parameter CANT_DATOS_SALIDA_ALU = `CANT_DATOS_SALIDA_ALU;
	parameter WIDTH_WORD = `WIDTH_WORD;
	
	//Todo puerto de salida del modulo es un cable.
	//Todo puerto de estimulo o generacion de entrada es un registro.
	
	// Entradas.
    reg reg_reset;
	reg [CANT_DATOS_SALIDA_ALU - 1 : 0] reg_resultado_alu; 
	reg [WIDTH_WORD - 1 : 0] reg_data_rx;
	reg reg_rx_done;                     
    reg reg_tx_done;
	reg reg_clock;
	                       
    
	// Salidas.
	wire wire_tx_start;
	wire [WIDTH_WORD - 1 : 0] wire_data_tx;
	wire [CANT_DATOS_ENTRADA_ALU - 1 : 0] wire_dato_A;
	wire [CANT_DATOS_ENTRADA_ALU - 1 : 0] wire_dato_B;
	wire [CANT_BITS_OPCODE_ALU - 1 : 0] wire_opcode;
    
	
	
	initial	begin
		reg_clock = 1'b0;
		reg_reset = 1'b0; // Reset en 0. (Normal cerrado el boton del reset).
		reg_data_rx = 0;
		reg_resultado_alu = 0;
		reg_rx_done = 1'b0;
		reg_tx_done = 1'b0;

		#10 reg_reset = 1'b1; // Desactivo la accion del reset.
		
		// Test 1: Rx done. ESPERA -> OPERANDO1.
		#900 reg_data_rx = 2;
		#1000 reg_rx_done = 1'b1;
		#1500 reg_rx_done = 1'b0;

		// Test 2: Rx done. OPERANDO1 -> OPERACION.
		#900 reg_data_rx = 3;
		#1000 reg_rx_done = 1'b1;
		#1500 reg_rx_done = 1'b0;

		// Test 3: Rx done. OPERACION -> OPERANDO2.
		#900 reg_data_rx = 1;
		#1000 reg_rx_done = 1'b1;
		#1500 reg_rx_done = 1'b0;

		// Test 4: Tx done. OPERANDO2 -> ESPERA.
		#900 reg_resultado_alu = 3;
		#1000 reg_tx_done = 1'b1;
		#10 reg_resultado_alu = 4;
		#1500 reg_tx_done = 1'b0;

		// Test 5: Prueba reset.
		#50000 reg_reset = 1'b0; // Reset.
		#10 reg_reset = 1'b1; // Desactivo el reset.

		#1000000 $finish;
	end
	
	always #2.5 reg_clock = ~reg_clock;  // Simulacion de clock.



//Modulo para pasarle los estimulos del banco de pruebas.
interface_circuit
    #(
         .CANT_DATOS_ENTRADA_ALU (CANT_DATOS_ENTRADA_ALU),
         .CANT_DATOS_SALIDA_ALU (CANT_DATOS_SALIDA_ALU),
		 .CANT_BITS_OPCODE_ALU (CANT_BITS_OPCODE_ALU),
		 .WIDTH_WORD (WIDTH_WORD)
     ) 
    u_interface_circuit_1    // Una sola instancia de este modulo.
    (
      	.i_clock (reg_clock),
      	.i_reset (reg_reset),
		.i_resultado_alu (reg_resultado_alu),
		.i_data_rx (reg_data_rx),
		.i_rx_done (reg_rx_done),
		.i_tx_done (reg_tx_done),
		.o_tx_start (wire_tx_start),
		.o_data_tx (wire_data_tx),
		.o_reg_dato_A (wire_dato_A),
		.o_reg_dato_B (wire_dato_B),
		.o_reg_opcode (wire_opcode)
    );
   
endmodule

 
