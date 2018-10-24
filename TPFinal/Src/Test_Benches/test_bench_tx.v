 
 `timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Test bench del modulo tx.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////

`define WIDTH_WORD_TX           8       // Longitud de palabra útil a enviar por la trama UART.          
`define CANT_BIT_STOP_TEST      2       // Cantidad de bits de stop en la trama UART.

module test_bench_tx();
		
	// Parametros
    parameter WIDTH_WORD_TX = `WIDTH_WORD_TX;
    parameter CANT_BIT_STOP_TEST = `CANT_BIT_STOP_TEST;
	
	//Todo puerto de salida del modulo es un cable.
	//Todo puerto de estimulo o generacion de entrada es un registro.
	
	// Entradas.
    reg clock;                                  // Clock.
    reg rate;
    reg hard_reset;                             // Reset.
    reg tx_start;
    reg [WIDTH_WORD_TX-1:0] data_in;                                 
    wire bit_tx;
    wire tx_done;
    
	
	
	initial	begin
        rate = 1'b0;
		clock = 1'b0;
		hard_reset = 1'b0; // Reset en 0. (Normal cerrado el boton del reset).
		data_in = 8'b00000000;
        tx_start = 1'b0;
		#10 hard_reset = 1'b1; // Desactivo la accion del reset.
		
        // Test 1: Envío de dato.
		#160 data_in = 8'b10010110; // Dato a enviar
		
        #160 tx_start = 1'b1; // Enviar ahora
        #100 tx_start = 1'b0;

        // Test 2: Envío de dato.
        #1160 data_in = 8'b10000110; // Dato a enviar
		#160 tx_start = 1'b1; // Enviar ahora
        #100 tx_start = 1'b0; 
        
        // Test 3: Prueba tx_start.
        #1000 tx_start = 1'b1; // Enviar ahora
        #100 tx_start = 1'b0; 
                
		// Test 4: Prueba reset.
		#10000 hard_reset = 1'b0; // Reset.
		#10000 hard_reset = 1'b1; // Desactivo el reset.
		
		
		#500000 $finish;
	end
	
	always #2.5 clock=~clock;  // Simulacion de clock.
    always #5 rate=~rate;  // Simulacion de rate.


// Modulo para pasarle los estimulos del banco de pruebas.
tx
    #(
         .WIDTH_WORD_TX (WIDTH_WORD_TX),
         .CANT_BIT_STOP (CANT_BIT_STOP_TEST)
     ) 
    u_tx_1    
    (
      .i_clock (clock),
      .i_rate (rate),
      .i_data_in (data_in),
      .i_reset (hard_reset),
      .i_tx_start (tx_start),
      .o_bit_tx (bit_tx),
      .o_tx_done (tx_done)
    );
   
endmodule

 
 
