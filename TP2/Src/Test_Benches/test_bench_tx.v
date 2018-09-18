 
 `timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 2. UART.
// Test bench del modulo baud_rate_generator.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////

`define WIDTH_WORD_TX           8                 
`define CANT_BIT_STOP_TEST      2     

module test_bench_tx();
		
	// Parametros
    parameter WIDTH_WORD_TX = `WIDTH_WORD_TX;
    parameter CANT_BIT_STOP_TEST = `CANT_BIT_STOP_TEST;
	
	//Todo puerto de salida del modulo es un cable.
	//Todo puerto de estimulo o generacion de entrada es un registro.
	
	// Entradas.
    reg clock;                                  // Clock rate.
    reg hard_reset;                             // Reset.
    reg tx_start;
    reg [WIDTH_WORD_TX-1:0] data_in;                                 // bit entrada al modulo rx
    wire bit_tx;
    wire tx_done;
    
	
	
	initial	begin
		clock = 1'b0;
		hard_reset = 1'b0; // Reset en 0. (Normal cerrado el boton del reset).
		data_in = 8'b00000000;
        tx_start = 1'b0;
		#10 hard_reset = 1'b1; // Desactivo la accion del reset.
		
		#80 data_in = 8'b10010110; //dato a enviar
		
        #80 tx_start = 1'b1; //enviar ahora
        #100 tx_start = 1'b0;

        #80 data_in = 8'b10000110; //dato a enviar
		
		// Test 1: Prueba reset.
		#10000 hard_reset = 1'b0; // Reset.
		#10000 hard_reset = 1'b1; // Desactivo el reset.
		
		
		#500000 $finish;
	end
	
	always #2.5 clock=~clock;  // Simulacion de clock.



//Modulo para pasarle los estimulos del banco de pruebas.
tx
    #(
         .WIDTH_WORD_TX (WIDTH_WORD_TX),
         .CANT_BIT_STOP (CANT_BIT_STOP_TEST)
     ) 
    u_tx_1    // Una i_tx_startsola instancia de este modulo.
    (
      .i_rate (clock),
      .i_data_in (data_in),
      .i_reset (hard_reset),
      .i_tx_start (tx_start),
      .o_bit_tx (bit_tx),
      .o_tx_done (tx_done)
    );
   
endmodule

 
 
