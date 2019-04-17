 
 `timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Test bench del top de la etapa de memoria de datos.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////

module test_bench_top_mem();
		
	// Parametros
    parameter RAM_WIDTH = 32;
    parameter RAM_PERFORMANCE = "LOW_LATENCY";
    parameter INIT_FILE = "";
    parameter RAM_DEPTH = 1024;
    parameter CANT_COLUMNAS_MEM_DATOS = 4;
    parameter CANT_REGISTROS= 32;
    parameter CANT_BITS_ADDR = 12; // Los dos bits LSB direccionan a nivel de byte.
    parameter CANT_BITS_REGISTROS = 32;
    parameter CANT_BITS_SELECT_BYTES_MEM_DATA = 3;
	
	//Todo puerto de salida del modulo es un cable.
	//Todo puerto de estimulo o generacion de entrada es un registro.
	//  The following function calculates the address width based on specified RAM depth
    function integer clogb2;
        input integer depth;
            for (clogb2=0; depth>0; clogb2=clogb2+1)
                depth = depth >> 1;
    endfunction
    
	// ENTRADAS.
    reg reg_clock;
    reg reg_soft_reset;
    
    reg reg_enable_pipeline;
    
    reg reg_halt_detected;
    reg reg_control_write_read_mem;
    reg reg_control_address_mem;
    reg reg_enable_mem_datos;
    reg reg_rsta;
    reg reg_regcea;

    reg [CANT_BITS_REGISTROS - 1 : 0] reg_address_ALU;
    reg [CANT_BITS_ADDR - 1 : 0] reg_address_debug_unit;
    reg [CANT_BITS_REGISTROS - 1 : 0] reg_data_write_mem;
    
    
    // Control

    
    reg reg_RegWrite;
    reg reg_MemRead;
    reg reg_MemWrite;
    reg reg_MemtoReg;
    reg [CANT_BITS_SELECT_BYTES_MEM_DATA - 1 : 0] reg_select_bytes_mem_datos;
    reg [clogb2 (CANT_REGISTROS - 1) - 1 : 0] reg_registro_destino;

    
    
    wire wire_RegWrite;
    wire wire_MemtoReg;
    wire [clogb2 (CANT_REGISTROS - 1) - 1 : 0] wire_registro_destino;
    wire wire_halt_detected;
    wire [CANT_BITS_REGISTROS - 1 : 0] wire_data_alu;
    wire [CANT_BITS_REGISTROS - 1 : 0] wire_data_mem;
    
    wire wire_soft_reset_ack;
    
    wire [CANT_BITS_REGISTROS - 1 : 0] wire_dato_mem_to_debug_unit;
    wire wire_bit_sucio_to_debug_unit;

    wire [2 : 0] wire_led;

	
	
	initial	begin
        reg_clock = 1'b0;
        reg_soft_reset = 1'b1;
        reg_enable_pipeline = 1'b1;
        reg_halt_detected = 1'b0;
        reg_control_write_read_mem = 1'b0;
        reg_control_address_mem = 1'b0;
        
        reg_enable_mem_datos = 1'b1;
        reg_rsta = 1'b0;
        reg_regcea = 1'b0;
        reg_address_ALU = 8;
        reg_address_debug_unit = 2;
        reg_data_write_mem = 32'hFFDECBAA;    
        reg_RegWrite = 1;
        reg_MemRead = 0;
        reg_MemWrite = 0;
        reg_MemtoReg = 0;
        reg_select_bytes_mem_datos = 0;
        reg_registro_destino = 5;

		#10 reg_soft_reset = 1'b0; // Reset.
		#30000 reg_soft_reset = 1'b1; // Desactivo el reset.
		
        #10 reg_MemWrite = 1;
        #10 reg_select_bytes_mem_datos = 3;
        #10 reg_control_write_read_mem = 1'b1;
        #10 reg_MemWrite = 0;
        #10 reg_select_bytes_mem_datos = 0;
        #50 reg_control_write_read_mem = 1'b0;

        #10 reg_control_address_mem = 1'b1;
        #10 reg_control_address_mem = 1'b0;


        #10 reg_MemRead = 1'b1;
        #10 reg_MemRead = 1'b0;

        #10 reg_MemWrite = 1; 
        

        #10 reg_select_bytes_mem_datos = 3; 
        #10 reg_address_ALU = 9;
        #10 reg_select_bytes_mem_datos = 2;

        #10 reg_select_bytes_mem_datos = 1;

 
        #10 reg_MemWrite = 0;    
        


		#10 reg_soft_reset = 1'b0; // Reset.
		#30000 reg_soft_reset = 1'b1; // Desactivo el reset.

		#500000 $finish;
	end
	
	always #2.5 reg_clock=~reg_clock;  // Simulacion de clock.
    


// Modulo para pasarle los estimulos del banco de pruebas.
top_mem
    #(
        .RAM_WIDTH (RAM_WIDTH),
        .RAM_PERFORMANCE (RAM_PERFORMANCE),
        .INIT_FILE (INIT_FILE),
        .RAM_DEPTH (RAM_DEPTH),
        .CANT_COLUMNAS_MEM_DATOS (CANT_COLUMNAS_MEM_DATOS),
        .CANT_REGISTROS (CANT_REGISTROS),
        .CANT_BITS_ADDR (CANT_BITS_ADDR), // Los dos bits LSB direccionan a nivel de byte.
        .CANT_BITS_REGISTROS (CANT_BITS_REGISTROS),
        .CANT_BITS_SELECT_BYTES_MEM_DATA (CANT_BITS_SELECT_BYTES_MEM_DATA)
     ) 
    u_top_mem_1    
    (
        .i_clock (reg_clock),
        .i_soft_reset (reg_soft_reset),
        
        .i_enable_pipeline (reg_enable_pipeline),
        
        .i_halt_detected (reg_halt_detected),
        .i_control_write_read_mem (reg_control_write_read_mem),
        .i_control_address_mem (reg_control_address_mem),
        .i_enable_mem_datos (reg_enable_mem_datos),
        .i_rsta (reg_rsta),
        .i_regcea (reg_regcea),

        .i_address_ALU (reg_address_ALU),
        .i_address_debug_unit (reg_address_debug_unit),
        .i_data_write_mem (reg_data_write_mem),
        
        .i_RegWrite (reg_RegWrite),
        .i_MemRead (reg_MemRead),
        .i_MemWrite (reg_MemWrite),
        .i_MemtoReg (reg_MemtoReg),
        .i_select_bytes_mem_datos (reg_select_bytes_mem_datos),
        .i_registro_destino (reg_registro_destino),
        .o_RegWrite (wire_RegWrite),
        .o_MemtoReg (wire_MemtoReg),
        .o_registro_destino (wire_registro_destino),
        .o_halt_detected (wire_halt_detected),
        .o_data_alu (wire_data_alu),
        .o_data_mem (wire_data_mem),
        .o_soft_reset_ack (wire_soft_reset_ack),
        .o_dato_mem_to_debug_unit (wire_dato_mem_to_debug_unit),
        .o_bit_sucio_to_debug_unit (wire_bit_sucio_to_debug_unit),

        .o_led (wire_led)
    );
   
endmodule

 
 
