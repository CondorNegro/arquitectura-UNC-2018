 `timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Test bench del modulo rx.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////

`define WIDTH_WORD_TEST         8   	// Longitud de palabra útil enviada por la trama UART.              
`define CANT_BIT_STOP_TEST      2		// Cantidad de bits de stop en la trama UART.     

module test_bench_rx();
		
	// Parametros
    parameter WIDTH_WORD_TEST = `WIDTH_WORD_TEST;
    parameter CANT_BIT_STOP_TEST = `CANT_BIT_STOP_TEST;
	
	//Todo puerto de salida del modulo es un cable.
	//Todo puerto de estimulo o generacion de entrada es un registro.
	
	// Entradas.
    reg clock;                                  // Clock.
	reg rate; 									// Rate. (Baud rate generator).
    reg hard_reset;                             // Reset.
    reg bit_rx;                                 // Bit de entrada al modulo rx
    wire rx_done;
    wire [WIDTH_WORD_TEST-1:0] data_out;
    
	
	
	initial	begin
		clock = 1'b0;
		rate = 1'b0;
		hard_reset = 1'b0; // Reset en 0. (Normal cerrado el boton del reset).
		bit_rx = 1'b1;
		#10 hard_reset = 1'b1; // Desactivo la accion del reset.
		

		// Test 1: Envío de trama correcta.
		#160 bit_rx = 1'b0; //bit inicio
		
		#160 bit_rx = 1'b1; // dato - 8 bits (1001 0110)
		#160 bit_rx = 1'b0; // 160 viene dado porque cada 5 instantes de tiempo cambia el estado del rate
		#160 bit_rx = 1'b0; // o sea, cada 10 instantes de tiempo hay un nuevo tick
		#160 bit_rx = 1'b1; // entonces 16 * 10 = 160
		#160 bit_rx = 1'b0;
		#160 bit_rx = 1'b1;
		#160 bit_rx = 1'b1;
		#160 bit_rx = 1'b0;
		
		#160 bit_rx = 1'b1; //bits stop
		#160 bit_rx = 1'b1; //bits stop

		// Test 2: Envío de trama errónea.
		#160 bit_rx = 1'b0; //bit inicio
		
		#160 bit_rx = 1'b1; // dato - 8 bits (1001 0110)
		#160 bit_rx = 1'b0; // 160 viene dado porque cada 5 instantes de tiempo cambia el estado del rate
		#160 bit_rx = 1'b0; // o sea, cada 10 instantes de tiempo hay un nuevo tick
		#160 bit_rx = 1'b1; // entonces 16 * 10 = 160
		#160 bit_rx = 1'b0;
		#160 bit_rx = 1'b1;
		#160 bit_rx = 1'b1;
		#160 bit_rx = 1'b0;
		
		#160 bit_rx = 1'b1; //bits stop
		#160 bit_rx = 1'b0; //bits stop mal.


		
		// Test 3: Prueba reset.
		#10000 hard_reset = 1'b0; // Reset.
		#10000 hard_reset = 1'b1; // Desactivo el reset.
		
		
		#500000 $finish;
	end
	
	always #2.5 clock=~clock;  // Simulacion de clock.
	always #5 rate=~rate;	   // Simulacion de rate.


//Modulo para pasarle los estimulos del banco de pruebas.
rx
    #(
         .WIDTH_WORD (WIDTH_WORD_TEST),
         .CANT_BIT_STOP (CANT_BIT_STOP_TEST)
     ) 
    u_rx_1    // Una sola instancia de este modulo.
    (
      .i_rate (rate),
      .i_bit_rx (bit_rx),
      .i_reset (hard_reset),
      .i_clock (clock),
      .o_rx_done (rx_done),
      .o_data_out (data_out)
    );
   
endmodule

 
 
