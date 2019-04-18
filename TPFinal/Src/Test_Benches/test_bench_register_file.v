
 `timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Test bench del modulo register file.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////


module test_bench_register_file();

    parameter CANTIDAD_REGISTROS = 32;
    parameter CANTIDAD_BITS_REGISTROS = 32;
    parameter CANTIDAD_BITS_ADDRESS_REGISTROS = 5;


    //Todo puerto de salida del modulo es un cable.
	//Todo puerto de estimulo o generacion de entrada es un registro.

	// Entradas.
    reg reg_clock;                                  // Clock.
    reg reg_soft_reset;                             // Reset.
    reg [CANTIDAD_BITS_ADDRESS_REGISTROS - 1 : 0] reg_A;
    reg [CANTIDAD_BITS_ADDRESS_REGISTROS - 1 : 0] reg_B;
    reg [CANTIDAD_BITS_ADDRESS_REGISTROS - 1 : 0] reg_reg_write; 
    reg [CANTIDAD_BITS_REGISTROS - 1 : 0] reg_data_write;
    reg reg_control_write;
    reg reg_enable_pipeline;
    reg [CANTIDAD_BITS_ADDRESS_REGISTROS - 1 : 0] reg_reg_read_from_debug_unit;
    wire [CANTIDAD_BITS_REGISTROS - 1 : 0] wire_reg_data_to_debug_unit;
    wire [CANTIDAD_BITS_REGISTROS - 1 : 0] wire_data_A;
    wire [CANTIDAD_BITS_REGISTROS - 1 : 0] wire_data_B;
    wire wire_led;

	initial	begin
	   reg_clock = 1'b0;
       reg_soft_reset = 1'b0; // Reset en 0. 
	   reg_A = 2;
	   reg_B = 0;
       reg_reg_write = 0;
       reg_data_write = 5;
       reg_control_write = 0;
       reg_reg_read_from_debug_unit = 0;
       reg_enable_pipeline = 1;
	   
       #100 reg_soft_reset = 1'b1; // Desactivo la accion del reset.

       
       #200 reg_control_write = 1'b1; //Escribo R0. Led se prende.
       #10  reg_control_write = 1'b0;

       #100 reg_A = 3; // Cambio seleccion de registro.
       #100 reg_B = 4; // Cambio seleccion de registro.

       #100 reg_A = 31; // Cambio seleccion de registro.
       #100 reg_B = 31; // Cambio seleccion de registro.

       #10 reg_reg_read_from_debug_unit = 1; // Leo R1 desde debug unit
	   
	   // Test 4: Prueba reset.
	   #1000 reg_soft_reset = 1'b0; // Reset.
	   #1000 reg_soft_reset = 1'b1; // Desactivo el reset.


		#500000 $finish;
	end

	always #2.5 reg_clock = ~reg_clock;  // Simulacion de clock.


// Modulo para pasarle los estimulos del banco de pruebas.
register_file
    #(
        .CANTIDAD_REGISTROS (CANTIDAD_REGISTROS),
        .CANTIDAD_BITS_REGISTROS (CANTIDAD_BITS_REGISTROS),
        .CANTIDAD_BITS_ADDRESS_REGISTROS (CANTIDAD_BITS_ADDRESS_REGISTROS)
    )
    u_register_file_1
    (
        .i_clock (reg_clock),
        .i_soft_reset (reg_soft_reset),
        .i_reg_A (reg_A),
        .i_reg_B (reg_B),
        .i_reg_Write (reg_reg_write),
        .i_data_write (reg_data_write),
        .i_control_write (reg_control_write),
        .i_reg_read_from_debug_unit (reg_reg_read_from_debug_unit),
        .i_enable_pipeline (reg_enable_pipeline),
        .o_reg_data_to_debug_unit (wire_reg_data_to_debug_unit),
        .o_data_A (wire_data_A),
        .o_data_B (wire_data_B),
        .o_led (wire_led)
    );

endmodule
