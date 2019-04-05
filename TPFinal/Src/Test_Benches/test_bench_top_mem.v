 
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
    parameter WIDTH_DATA_MEM = 32;
    parameter CANT_REGISTROS= 32;
    parameter CANT_BITS_ADDR = 11;
    parameter CANT_BITS_REGISTROS = 32;
    parameter CANT_BITS_ALU_CONTROL = 4;
	
	//Todo puerto de salida del modulo es un cable.
	//Todo puerto de estimulo o generacion de entrada es un registro.
	//  The following function calculates the address width based on specified RAM depth
    function integer clogb2;
        input integer depth;
            for (clogb2=0; depth>0; clogb2=clogb2+1)
                depth = depth >> 1;
    endfunction
    
	// ENTRADAS.
    reg reg_i_clock;
    reg reg_i_soft_reset;
    reg reg_i_enable_pipeline;
    reg [CANT_BITS_ADDR - 1 : 0]  reg_i_adder_pc;
    reg [CANT_BITS_REGISTROS - 1 : 0] reg_i_data_A;
    reg [CANT_BITS_REGISTROS - 1 : 0] reg_i_data_B;
    reg [CANT_BITS_REGISTROS - 1 : 0] reg_i_extension_signo_constante;
    reg [clogb2 (CANT_REGISTROS - 1) - 1 : 0] reg_i_reg_rs;
    reg [clogb2 (CANT_REGISTROS - 1) - 1 : 0] reg_i_reg_rt;
    reg [clogb2 (CANT_REGISTROS - 1) - 1 : 0] reg_i_reg_rd;
    // Control
    reg reg_i_RegDst;
    reg reg_i_RegWrite;
    reg reg_i_ALUSrc;
    reg reg_i_MemRead;
    reg reg_i_MemWrite;
    reg reg_i_MemtoReg;
    reg [CANT_BITS_ALU_CONTROL - 1 : 0] reg_i_ALUCtrl;                               
    
    //SALIDAS.
    wire wire_o_RegWrite;
    wire wire_o_MemRead;
    wire wire_o_MemWrite;
    wire wire_o_MemtoReg;


    wire [WIDTH_DATA_MEM - 1 : 0] wire_o_result;
    wire [WIDTH_DATA_MEM - 1 : 0] wire_o_data_write_to_mem;
    wire [clogb2 (CANT_REGISTROS - 1) - 1 : 0] wire_o_registro_destino;

    wire wire_o_led;
    
	
	
	initial	begin
        reg_i_soft_reset = 1'b1;
        reg_i_clock = 0;

        reg_i_enable_pipeline = 1'b1;

        reg_i_adder_pc = 5;
        reg_i_data_A = 0;
        reg_i_data_B = 0;
        reg_i_extension_signo_constante = 20;
        reg_i_reg_rs = 1;
        reg_i_reg_rt = 2;
        reg_i_reg_rd = 3;
        reg_i_RegDst = 0;
        reg_i_RegWrite = 0;
        reg_i_ALUSrc = 0;
        reg_i_MemRead = 0;
        reg_i_MemWrite = 0;
        reg_i_MemtoReg = 0;
        reg_i_ALUCtrl = 4'b0010;

        #20 reg_i_soft_reset = 1'b0;
        #20 reg_i_soft_reset = 1'b1;
        #20 reg_i_enable_pipeline = 1'b0;
        #20 reg_i_data_A = 1;
        #20 reg_i_enable_pipeline = 1'b1;
        #20 reg_i_data_B = 2;

        #20 reg_i_RegDst = 1; // Modifico selector de mux
        #20 reg_i_ALUSrc = 1; // Modifico selector de mux

        #20 reg_i_ALUCtrl = 4'b1000; // LUI
        #20 reg_i_ALUCtrl = 4'b1110; // SALTO
        #20 reg_i_ALUCtrl = 4'b0010; // ADDU
        #20 reg_i_ALUCtrl = 4'b0111; // SLTI
        
        #20 reg_i_ALUSrc = 0; // Modifico selector de mux
        #20 reg_i_data_B = -1; 
        #20 reg_i_data_A = -5; // Aca valor de ALU se debe invertir.


		#10000 reg_i_soft_reset = 1'b0; // Reset.
		#10000 reg_i_soft_reset = 1'b1; // Desactivo el reset.
		
		
		#500000 $finish;
	end
	
	always #2.5 reg_i_clock=~reg_i_clock;  // Simulacion de clock.
    


// Modulo para pasarle los estimulos del banco de pruebas.
top_ejecucion
    #(
        .WIDTH_DATA_MEM (WIDTH_DATA_MEM),
        .CANT_REGISTROS (CANT_REGISTROS),
        .CANT_BITS_ADDR (CANT_BITS_ADDR),
        .CANT_BITS_REGISTROS (CANT_BITS_REGISTROS),
        .CANT_BITS_ALU_CONTROL (CANT_BITS_ALU_CONTROL)
     ) 
    u_top_ejecucion_1    
    (
        .i_clock (reg_i_clock),
        .i_soft_reset (reg_i_soft_reset),
        .i_enable_pipeline (reg_i_enable_pipeline),
        .i_adder_pc (reg_i_adder_pc),
        .i_data_A (reg_i_data_A),
        .i_data_B (reg_i_data_B),
        .i_extension_signo_constante (reg_i_extension_signo_constante),
        .i_reg_rs (reg_i_reg_rs),
        .i_reg_rt (reg_i_reg_rt),
        .i_reg_rd (reg_i_reg_rd),
        // Control
        .i_RegDst (reg_i_RegDst),
        .i_RegWrite (reg_i_RegWrite),
        .i_ALUSrc (reg_i_ALUSrc),
        .i_MemRead (reg_i_MemRead),
        .i_MemWrite (reg_i_MemWrite),
        .i_MemtoReg (reg_i_MemtoReg),
        .i_ALUCtrl (reg_i_ALUCtrl), 


        .o_RegWrite (wire_o_RegWrite),
        .o_MemRead (wire_o_MemRead),
        .o_MemWrite (wire_o_MemWrite),
        .o_MemtoReg (wire_o_MemtoReg),


        .o_result (wire_o_result),
        .o_data_write_to_mem (wire_o_data_write_to_mem),
        .o_registro_destino (wire_o_registro_destino),
        .o_led (wire_o_led)
    );
   
endmodule

 
 
