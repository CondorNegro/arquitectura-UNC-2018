
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


    reg [CANT_BITS_ADDR_REGISTROS - 1 : 0] reg_i_rs_ex;
    reg [CANT_BITS_ADDR_REGISTROS - 1 : 0] reg_i_rt_ex;
    reg [CANT_BITS_ADDR_REGISTROS - 1 : 0] reg_i_registro_destino_mem;
    reg [CANT_BITS_ADDR_REGISTROS - 1 : 0] reg_i_registro_destino_wb;
    reg reg_i_reg_write_mem;
    reg reg_i_reg_write_wb;
    reg reg_enable_etapa;
    
    wire [CANT_BITS_SELECTOR_MUX - 1 : 0] wire_o_selector_mux_A;
    wire [CANT_BITS_SELECTOR_MUX - 1 : 0] wire_o_selector_mux_B;  
    wire [1 : 0] wire_leds; 
    

	initial	begin
	reg_i_rs_ex = 0;
    reg_i_rt_ex = 0;
    reg_i_registro_destino_mem = 0;
    reg_i_registro_destino_wb = 0;
    reg_i_reg_write_mem = 0;
    reg_i_reg_write_wb = 0;
    reg_enable_etapa = 1;
    
    #10 reg_i_reg_write_wb = 1'b1;
    
    
    #10 reg_i_reg_write_mem = 1'b1;
    #10 reg_i_registro_destino_mem = 5;
    #10 reg_i_rs_ex = 5;
    //o_selector_mux_A = 2 Forwarding from MEM
    
    #10 reg_i_registro_destino_wb = 5;
    //o_selector_mux_A = 2 Forwarding from MEM (SIGO)
    
    #10 reg_i_registro_destino_mem = 3; 
    //o_selector_mux_A = 1 Forwarding from MEM YA NO SIGO
    
    #10 reg_i_registro_destino_wb = 2;
    //o_selector_mux_A = 0 Forwarding from MEM
    
    
    
    #10 reg_i_rt_ex = 5;
    #10 reg_i_reg_write_mem = 1'b1;
    #10 reg_i_registro_destino_mem = 5;
    //o_selector_mux_B = 2 Forwarding from MEM
    
    #10 reg_i_registro_destino_wb = 5;
    //o_selector_mux_B = 2 Forwarding from MEM (SIGO)
    
    #10 reg_i_registro_destino_mem = 3; 
    //o_selector_mux_B = 1 Forwarding from MEM YA NO SIGO
    
    #10 reg_i_registro_destino_wb = 2;
    //o_selector_mux_B = 0 Forwarding from MEM (SIGO)
    
    

		#5000 $finish;
	end




// Modulo para pasarle los estimulos del banco de pruebas.
forwarding_unit
    #(
        .CANT_BITS_ADDR_REGISTROS (CANT_BITS_ADDR_REGISTROS),
        .CANT_BITS_SELECTOR_MUX (CANT_BITS_SELECTOR_MUX)
    )
    u_forwarding_unit_1
    (
        .i_rs_ex (reg_i_rs_ex),
        .i_rt_ex (reg_i_rt_ex),
        .i_registro_destino_mem (reg_i_registro_destino_mem),
        .i_registro_destino_wb (reg_i_registro_destino_wb),
        .i_reg_write_mem (reg_i_reg_write_mem),
        .i_reg_write_wb (reg_i_reg_write_wb),
        .i_enable_etapa (reg_enable_etapa),
        .o_led (wire_leds),

        .o_selector_mux_A (wire_o_selector_mux_A),
        .o_selector_mux_B (wire_o_selector_mux_B)   
    );

endmodule
