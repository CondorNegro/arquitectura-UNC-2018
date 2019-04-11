
 `timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Test bench del modulo forwarding unit.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////


module test_bench_forwarding_unit();

    parameter CANT_BITS_ADDR_REGISTROS = 5;
    parameter CANT_BITS_SELECTOR_MUX = 2;


    

	initial	begin
	   reg_clock = 1'b0;
       reg_soft_reset = 1'b0; // Reset en 0. 
	   reg_A = 2;
	   reg_B = 0;
       reg_reg_write = 0;
       reg_data_write = 5;
       reg_control_write = 0;
	   
       #100 reg_soft_reset = 1'b1; // Desactivo la accion del reset.

       
       #200 reg_control_write = 1'b1; //Escribo R1. Led se prende.
       #10  reg_control_write = 1'b0;

       #100 reg_A = 3; // Cambio seleccion de registro.
       #100 reg_B = 4; // Cambio seleccion de registro.

       #100 reg_A = 31; // Cambio seleccion de registro.
       #100 reg_B = 31; // Cambio seleccion de registro.
	   
	   // Test 4: Prueba reset.
	   #1000 reg_soft_reset = 1'b0; // Reset.
	   #1000 reg_soft_reset = 1'b1; // Desactivo el reset.


		#500000 $finish;
	end

	always #2.5 reg_clock = ~reg_clock;  // Simulacion de clock.


// Modulo para pasarle los estimulos del banco de pruebas.
forwarding_unit
    #(
        .CANTIDAD_REGISTROS (CANTIDAD_REGISTROS),
        .CANTIDAD_BITS_REGISTROS (CANTIDAD_BITS_REGISTROS),
        .CANTIDAD_BITS_ADDRESS_REGISTROS (CANTIDAD_BITS_ADDRESS_REGISTROS)
    )
    u_forwarding_unit_1
    (
        .i_clock (reg_clock),
        .i_soft_reset (reg_soft_reset),
        .i_reg_A (reg_A),
        .i_reg_B (reg_B),
        .i_reg_Write (reg_reg_write),
        .i_data_write (reg_data_write),
        .i_control_write (reg_control_write),
        .o_data_A (wire_data_A),
        .o_data_B (wire_data_B),
        .o_led (wire_led)
    );

endmodule
