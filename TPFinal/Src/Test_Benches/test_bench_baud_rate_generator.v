 `timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Test bench del modulo baud_rate_generator.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////

`define BAUD_RATE           9600            // Baud rate a generar.             
`define FREC_CLOCK_MHZ      100.0           // Frecuencia del clock en MHZ.

module test_bench_baud_rate_generator();
		
	// Parametros
    parameter BAUD_RATE = `BAUD_RATE;
    parameter FREC_CLOCK_MHZ = `FREC_CLOCK_MHZ;
	
	//Todo puerto de salida del modulo es un cable.
	//Todo puerto de estimulo o generacion de entrada es un registro.
	
	// Entradas.
    reg clock;                                  // Clock.
    reg hard_reset;                             // Reset.
    wire rate;
    
	
	
	initial	begin
		clock = 1'b0;
		hard_reset = 1'b0; // Reset en 0. (Normal cerrado el boton del reset).
		
		#10 hard_reset = 1'b1; // Desactivo la accion del reset.
		
		// Test 1: Prueba reset.
		#10000 hard_reset = 1'b0; // Reset.
		#10 hard_reset = 1'b1; // Desactivo el reset.
		
		
		#50000 $finish;
	end
	
	always #2.5 clock=~clock;  // Simulacion de clock.



//Modulo para pasarle los estimulos del banco de pruebas.
baud_rate_generator
    #(
         .BAUD_RATE (BAUD_RATE),
         .FREC_CLOCK_MHZ (FREC_CLOCK_MHZ)
     ) 
    u_baud_rate_generator_1    // Una sola instancia de este modulo.
    (
      .i_clock (clock),
      .i_reset (hard_reset),
      .o_rate (rate)
    );
   
endmodule

 
