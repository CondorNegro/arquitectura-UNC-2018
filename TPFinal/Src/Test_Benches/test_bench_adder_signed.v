`timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Test bench del modulo adder signado.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////


module test_bench_adder_signado();

    parameter INPUT_OUTPUT_LENGTH = 11;

    reg [INPUT_OUTPUT_LENGTH - 1 : 0] dato_A;
    reg [INPUT_OUTPUT_LENGTH - 1 : 0] dato_B;
    wire [INPUT_OUTPUT_LENGTH - 1 : 0] resultado;

	initial	begin
       dato_A = 1;
       dato_B = 2;
       #10 dato_A = {INPUT_OUTPUT_LENGTH {1'b1}};
       #10 dato_B = -2;
       #10 dato_A = 5;
       #10 dato_A = 11'b11111111100;


	   #100 $finish;
	end
	

// Modulo para pasarle los estimulos del banco de pruebas.
adder_signado
   #(
       .INPUT_OUTPUT_LENGTH (INPUT_OUTPUT_LENGTH)
   )
   u_adder_signado_1
   (
       .i_data_A (dato_A),
       .i_data_B (dato_B),
       .o_result (resultado)
   );

endmodule