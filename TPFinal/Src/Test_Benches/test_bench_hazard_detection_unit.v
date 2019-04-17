
 `timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Test bench del modulo hazard detection unit.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////


module test_bench_hazard_detection_unit();

    parameter CANT_BITS_ADDR_REGISTROS = 5;


    reg [CANT_BITS_ADDR_REGISTROS - 1 : 0] reg_rs_id;
    reg [CANT_BITS_ADDR_REGISTROS - 1 : 0] reg_rt_id;
    reg [CANT_BITS_ADDR_REGISTROS - 1 : 0] reg_registro_destino_ex;
    
    reg reg_read_mem_ex;
    reg reg_disable_for_exception;
    
    wire wire_bit_burbuja; 
    wire wire_led;  
    

	initial	begin
        reg_read_mem_ex = 0;
        reg_rs_id = 1;
        reg_rt_id = 2;
        reg_registro_destino_ex = 0;
        reg_disable_for_exception = 0;

        #10 reg_registro_destino_ex = 1;
        #20 reg_read_mem_ex = 1;
        #10 reg_disable_for_exception = 1;
        #10 reg_disable_for_exception = 0;
        #30 reg_registro_destino_ex = 2;
        #10 reg_registro_destino_ex = 3;
       

		#50 $finish;
	end




// Modulo para pasarle los estimulos del banco de pruebas.
hazard_detection_unit
    #(
        .CANT_BITS_ADDR_REGISTROS (CANT_BITS_ADDR_REGISTROS)
    )
    u_hazard_detection_unit_1
    (
        .i_rs_id (reg_rs_id),
        .i_rt_id (reg_rt_id),
        .i_registro_destino_ex (reg_registro_destino_ex),
        .i_read_mem_ex (reg_read_mem_ex),
        .i_disable_for_exception (reg_disable_for_exception),
        .o_led (wire_led),

        .o_bit_burbuja (wire_bit_burbuja) 
    );

endmodule
