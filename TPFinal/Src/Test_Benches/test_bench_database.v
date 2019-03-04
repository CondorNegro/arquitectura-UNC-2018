
 `timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Test bench del modulo database.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////


module test_bench_database();

     parameter ADDR_LENGTH = 11;
     parameter LONGITUD_INSTRUCCION = 32;
     parameter CANT_BITS_CONTROL = 3;
    //Todo puerto de salida del modulo es un cable.
	//Todo puerto de estimulo o generacion de entrada es un registro.

	// Entradas.
    reg clock;                                  // Clock.
    reg soft_reset;                             // Reset.
    reg [CANT_BITS_CONTROL - 1 : 0] control;

    // Intruction Fetch.
    reg [ADDR_LENGTH - 1 : 0] pc;
    reg [ADDR_LENGTH - 1 : 0] pc_plus_cuatro;
    reg [LONGITUD_INSTRUCCION - 1 : 0] instruction_fetch;


    wire [LONGITUD_INSTRUCCION - 1 : 0] wire_dato;

	initial	begin
	   clock = 1'b0;
	   soft_reset = 1'b1; // Reset en 0. (Normal cerrado el boton del reset).
	   control = 0;
	   pc = 4;
		 pc_plus_cuatro = 8;
		 instruction_fetch = 2;
	   
		 #10 soft_reset = 1'b0; // Desactivo la accion del reset.
	   #10 soft_reset = 1'b1; // Desactivo la accion del reset.
	   
		 #10 control = 1;
	  
		 #20 control = 3;

		 #20 control = 5;

		// Test 4: Prueba reset.
		#10000 soft_reset = 1'b0; // Reset.
		#10000 soft_reset = 1'b1; // Desactivo el reset.


		#500000 $finish;
	end

	always #2.5 clock=~clock;  // Simulacion de clock.


// Modulo para pasarle los estimulos del banco de pruebas.
database
    #(
         .ADDR_LENGTH (ADDR_LENGTH),
         .LONGITUD_INSTRUCCION (LONGITUD_INSTRUCCION),
				 .CANT_BITS_CONTROL (CANT_BITS_CONTROL)
     )
    u_database_1
    (
      .i_clock (clock),
      .i_soft_reset (soft_reset),
      .i_control (control),
      .i_pc (pc),
			.i_pc_plus_cuatro (pc_plus_cuatro),
			.i_instruction_fetch (instruction_fetch),
      .o_dato (wire_dato)
    );

endmodule
