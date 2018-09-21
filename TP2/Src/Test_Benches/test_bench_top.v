 `timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 2. UART.
// Test bench del top.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////

`define BUS_DATOS_ALU_TEST       8       // Tamanio del bus de entrada de la ALU. 
`define BUS_SALIDA_ALU_TEST      8       // Tamanio del bus de salida de la ALU.
`define CANT_BIT_OPCODE_TEST     8       // Numero de bits del codigo de operacion de la ALU.
`define WIDTH_WORD_TOP_TEST      8       // Tamanio de palabra de trama UART.    
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
   reg clock;                                  // Clock.
   reg hard_reset;                             // Reset.
   reg uart_txd_in_reg;                        // Tx de PC.
   wire uart_rxd_out_wire;                     // Rx de PC.
   
   
   
   initial    begin
		clock = 1'b0;
		hard_reset = 1'b0; // Reset en 0. (Normal cerrado el boton del reset).
		uart_txd_in_reg = 1'b1;

		#2000 hard_reset = 1'b1; // Desactivo la accion del reset.
		
        
        // Test 1: Transmito primer operando.
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


        // Dejo un intervalo de tiempo.
		#52080 uart_txd_in_reg = 1'b1;

        // Test 2: Transmito codigo de operacion.
		#52080 uart_txd_in_reg = 1'b0;	
        #52080 uart_txd_in_reg = 1'b0;
        #52080 uart_txd_in_reg = 1'b0;
        #52080 uart_txd_in_reg = 1'b1;
        #52080 uart_txd_in_reg = 1'b0;
        #52080 uart_txd_in_reg = 1'b0;
        #52080 uart_txd_in_reg = 1'b0;
        #52080 uart_txd_in_reg = 1'b0;
        #52080 uart_txd_in_reg = 1'b0;
        #52080 uart_txd_in_reg = 1'b1;
        #52080 uart_txd_in_reg = 1'b1;
        
        // Dejo un intervalo de tiempo.
        #52080 uart_txd_in_reg = 1'b1;
        

        // Test 3: Transmito tercer operando.
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

		// Test 4: Prueba reset.
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
   u_top_arquitectura_1
   (
     .i_clock (clock),
     .i_reset (hard_reset),
     .uart_txd_in (uart_txd_in_reg),
     .uart_rxd_out (uart_rxd_out_wire)
   );
  
endmodule