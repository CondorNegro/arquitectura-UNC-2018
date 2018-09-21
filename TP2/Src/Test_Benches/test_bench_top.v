 `timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 2. UART.
// Test bench del modulo baud_rate_generator.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////

`define BUS_DATOS_ALU_TEST       8       // Tamanio del bus de entrada. 
`define BUS_SALIDA_ALU_TEST      8       // Tamanio del bus de salida.
`define CANT_BIT_OPCODE_TEST     8       // Numero de bits del codigo de operacion de la ALU.
`define WIDTH_WORD_TOP_TEST      8       // Tamanio de palabra.    
`define FREC_CLK_MHZ_TEST    100.0       // Frecuencia del clock en MHZ.
`define BAUD_RATE_TOP_TEST    9600       // Baud rate.
`define CANT_BIT_STOP_TOP_TEST   2       // Cantidad de bits de parada en trama uart.        

module test_bench_top_arquitectura();
       
   // Parametros
   parameter BUS_DATOS_ALU_TEST     = `BUS_DATOS_ALU_TEST;
   parameter BUS_SALIDA_ALU_TEST    = `BUS_SALIDA_ALU_TEST;
   parameter CANT_BIT_OPCODE_TEST   = `CANT_BIT_OPCODE_TEST;
   parameter WIDTH_WORD_TOP_TEST    = `WIDTH_WORD_TOP_TEST;
   parameter FREC_CLK_MHZ_TEST      = `FREC_CLK_MHZ_TEST;
   parameter BAUD_RATE_TOP_TEST     = `BAUD_RATE_TOP_TEST;
   parameter CANT_BIT_STOP_TOP_TEST = `CANT_BIT_STOP_TOP_TEST;
   
   //Todo puerto de salida del modulo es un cable.
   //Todo puerto de estimulo o generacion de entrada es un registro.
   
   // Entradas.
   reg clock;                                  // Clock rate.
   reg hard_reset;                             // Reset.
   reg uart_txd_in_reg;
   wire uart_rxd_out_wire;
   
   
   
   initial    begin
		clock = 1'b0;
		hard_reset = 1'b0; // Reset en 0. (Normal cerrado el boton del reset).
		uart_txd_in_reg = 1'b1;

		#2000 hard_reset = 1'b1; // Desactivo la accion del reset.
		
		#52080 uart_txd_in_reg = 1'b0;
		#52080 uart_txd_in_reg = 1'b0;
		#52080 uart_txd_in_reg = 1'b0;
		#52080 uart_txd_in_reg = 1'b0;
		#52080 uart_txd_in_reg = 1'b0;
		#52080 uart_txd_in_reg = 1'b0;
		#52080 uart_txd_in_reg = 1'b0;
		#52080 uart_txd_in_reg = 1'b0;
		#52080 uart_txd_in_reg = 1'b0;
		#52080 uart_txd_in_reg = 1'b1;
		#52080 uart_txd_in_reg = 1'b1;
		
		#52080 uart_txd_in_reg = 1'b1;
		
		#52080 uart_txd_in_reg = 1'b0;
			
        #52080 uart_txd_in_reg = 1'b0;
        #52080 uart_txd_in_reg = 1'b0;
        #52080 uart_txd_in_reg = 1'b0;
        #52080 uart_txd_in_reg = 1'b1;
        #52080 uart_txd_in_reg = 1'b0;
        #52080 uart_txd_in_reg = 1'b0;
        #52080 uart_txd_in_reg = 1'b0;
        #52080 uart_txd_in_reg = 1'b0;
        #52080 uart_txd_in_reg = 1'b1;
        #52080 uart_txd_in_reg = 1'b1;
        
        #52080 uart_txd_in_reg = 1'b1;
        
        #52080 uart_txd_in_reg = 1'b0;
        #52080 uart_txd_in_reg = 1'b0;
        #52080 uart_txd_in_reg = 1'b0;
        #52080 uart_txd_in_reg = 1'b0;
        #52080 uart_txd_in_reg = 1'b0;
        #52080 uart_txd_in_reg = 1'b0;
        #52080 uart_txd_in_reg = 1'b0;
        #52080 uart_txd_in_reg = 1'b0;
        #52080 uart_txd_in_reg = 1'b0;
        #52080 uart_txd_in_reg = 1'b1;
        #52080 uart_txd_in_reg = 1'b1;

		// Test 1: Prueba reset.
		#1000000 hard_reset = 1'b0; // Reset.
		#1000000 hard_reset = 1'b1; // Desactivo el reset.


		#5000000 $finish;
   end
   
   always #2.5 clock=~clock;  // Simulacion de clock.



//Modulo para pasarle los estimulos del banco de pruebas.
top_arquitectura
   #(
       .BUS_DATOS_ALU (BUS_DATOS_ALU_TEST),
       .BUS_SALIDA_ALU (BUS_SALIDA_ALU_TEST),
       .CANT_BIT_OPCODE (CANT_BIT_OPCODE_TEST),
       .WIDTH_WORD_TOP (WIDTH_WORD_TOP_TEST),
       .FREC_CLK_MHZ (FREC_CLK_MHZ_TEST),
       .BAUD_RATE_TOP (BAUD_RATE_TOP_TEST),
       .CANT_BIT_STOP_TOP (CANT_BIT_STOP_TOP_TEST)
    ) 
   u_top_arquitectura_1    // Una i_tx_startsola instancia de este modulo.
   (
     .i_clock (clock),
     .i_reset (hard_reset),
     .uart_txd_in (uart_txd_in_reg),
     .uart_rxd_out (uart_rxd_out_wire)
   );
  
endmodule