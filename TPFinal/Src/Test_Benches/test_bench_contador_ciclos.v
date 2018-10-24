 
 `timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 3. BIP I.
// Test bench del modulo contador_ciclos.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////


module test_bench_contador_ciclos();
		
    parameter CONTADOR_LENGTH = 11	;   // Cantidad de bits del contador.
    //Todo puerto de salida del modulo es un cable.
	//Todo puerto de estimulo o generacion de entrada es un registro.
	
	// Entradas.
    reg clock;                                  // Clock.
    reg hard_reset;                             // Reset.
    
	wire [CONTADOR_LENGTH - 1 : 0] salida_cuenta;
	
	initial	begin
        
		clock = 1'b0;
		hard_reset = 1'b0; // Reset en 0. (Normal cerrado el boton del reset).
		#10 hard_reset = 1'b1; // Desactivo la accion del reset.
		
       
                
		// Test 4: Prueba reset.
		#10000 hard_reset = 1'b0; // Reset.
		#10000 hard_reset = 1'b1; // Desactivo el reset.
		
		
		#500000 $finish;
	end
	
	always #2.5 clock=~clock;  // Simulacion de clock.


// Modulo para pasarle los estimulos del banco de pruebas.
contador_ciclos
    #(
         .CONTADOR_LENGTH (CONTADOR_LENGTH)
     ) 
    u_contador_ciclos_1    
    (
      .i_clock (clock),
      .i_reset (hard_reset),
      .o_cuenta (salida_cuenta)
    );
   
endmodule

 
 
