 `timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 2. UART.
// Test bench del modulo baud_rate_generator.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////

`define WIDTH_WORD_TEST           8                 
`define CANT_BIT_STOP_TEST      2     

module test_bench_rx();
		
	// Parametros
    parameter WIDTH_WORD_TEST = `WIDTH_WORD_TEST;
    parameter CANT_BIT_STOP_TEST = `CANT_BIT_STOP_TEST;
	
	//Todo puerto de salida del modulo es un cable.
	//Todo puerto de estimulo o generacion de entrada es un registro.
	
	// Entradas.
    reg clock;                                  // Clock rate.
    reg hard_reset;                             // Reset.
    reg bit_rx;                                 // bit entrada al modulo rx
    wire rx_done;
    wire [WIDTH_WORD_TEST-1:0] data_out;
    
	
	
	initial	begin
		clock = 1'b0;
		hard_reset = 1'b0; // Reset en 0. (Normal cerrado el boton del reset).
		bit_rx = 1'b1;
		#10 hard_reset = 1'b1; // Desactivo la accion del reset.
		
		#80 bit_rx = 1'b0; //bit inicio
		
		#80 bit_rx = 1'b1; // dato - 8 bits (1001 0110)
		#80 bit_rx = 1'b0; // 80 viene dado porque cada 2.5 instantes de tiempo cambia el estado del clock (rate)
		#80 bit_rx = 1'b0; // o sea, cada 5 instantes de tiempo hay un nuevo tick
		#80 bit_rx = 1'b1; // entonces 16 * 5 = 80
		#80 bit_rx = 1'b0;
		#80 bit_rx = 1'b1;
		#80 bit_rx = 1'b1;
		#80 bit_rx = 1'b0;
		
		#80 bit_rx = 1'b1; //bits stop
		#80 bit_rx = 1'b1; //bits stop
		
		// Test 1: Prueba reset.
		#10000 hard_reset = 1'b0; // Reset.
		#10000 hard_reset = 1'b1; // Desactivo el reset.
		
		
		#500000 $finish;
	end
	
	always #2.5 clock=~clock;  // Simulacion de clock.



//Modulo para pasarle los estimulos del banco de pruebas.
rx
    #(
         .WIDTH_WORD (WIDTH_WORD_TEST),
         .CANT_BIT_STOP (CANT_BIT_STOP_TEST)
     ) 
    u_rx_1    // Una sola instancia de este modulo.
    (
      .i_rate (clock),
      .i_bit_rx (bit_rx),
      .i_reset (hard_reset),
      
      .o_rx_done (rx_done),
      .o_data_out (data_out)
    );
   
endmodule

 
 
