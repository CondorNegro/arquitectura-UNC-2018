 `timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 3. BIP I.
// Test bench del modulo address_calculator.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////


module test_bench_address_calculator();
		
    parameter PC_CANT_BITS = 11;    // Cantidad de bits del PC.
    parameter SUM_DIR = 1;          // Cantidad a sumar al PC para obtener la direccion siguiente.
  
    //Todo puerto de salida del modulo es un cable.
	//Todo puerto de estimulo o generacion de entrada es un registro.
	
	// Entradas.
    reg clock;                                  // Clock.
    reg hard_reset;                             // Reset.
    reg reg_i_wrPC;
	wire [PC_CANT_BITS-1:0] o_addr;
	
	initial	begin
	
        reg_i_wrPC = 1'b0;
		clock = 1'b0;
		hard_reset = 1'b0; // Reset en 0. (Normal cerrado el boton del reset).
		#10 hard_reset = 1'b1; // Desactivo la accion del reset.
		
        #100 reg_i_wrPC = 1'b1;
        #100 reg_i_wrPC = 1'b0;
        #1000 reg_i_wrPC = 1'b1;
        #1000 reg_i_wrPC = 1'b0;
        #10 reg_i_wrPC = 1'b1;
                
		// Test 4: Prueba reset.
		#10000 hard_reset = 1'b0; // Reset.
		#10000 hard_reset = 1'b1; // Desactivo el reset.
		
		
		#500000 $finish;
	end
	
	always #2.5 clock=~clock;  // Simulacion de clock.


// Modulo para pasarle los estimulos del banco de pruebas.
address_calculator
    #(
         .PC_CANT_BITS (PC_CANT_BITS),
         .SUM_DIR (SUM_DIR)
     ) 
    u_address_calculator_1    
    (
      .i_clock (clock),
      .i_reset (hard_reset),
      .i_wrPC(reg_i_wrPC),
      .o_addr (o_addr)
    );
   
endmodule

 
 
