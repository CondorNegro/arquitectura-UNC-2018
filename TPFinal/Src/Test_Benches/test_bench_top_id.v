 `timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Test bench del modulo top_id.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////




module test_bench_top_id();
		
		//  The following function calculates the address width based on specified RAM depth
    function integer clogb2;
        input integer depth;
            for (clogb2=0; depth>0; clogb2=clogb2+1)
                depth = depth >> 1;
    endfunction
    
	// Parametros
    parameter LENGTH_INSTRUCTION = 32;
    parameter CANT_REGISTROS= 32;
    parameter CANT_BITS_ADDR = 11;
    parameter CANT_BITS_REGISTROS = 32;
    parameter CANT_BITS_IMMEDIATE = 16;
    parameter CANT_BITS_ESPECIAL = 6;
    parameter CANT_BITS_CEROS = 5;
    parameter CANT_BITS_ID_LSB = 6;
    parameter CANT_BITS_INSTRUCTION_INDEX_BRANCH = 26;
    parameter CANT_BITS_FLAG_BRANCH = 3;
    parameter CANT_BITS_ALU_OP = 2;
    parameter CANT_BITS_ALU_CONTROL = 4;
    parameter HALT_INSTRUCTION = 32'hFFFFFFFF;
    parameter CANT_BITS_SELECT_BYTES_MEM_DATA = 3;   

	//Todo puerto de salida del modulo es un cable.
	//Todo puerto de estimulo o generacion de entrada es un registro.
	
	// Entradas y salidas
    reg reg_i_clock;
    reg reg_i_soft_reset;

    reg [LENGTH_INSTRUCTION - 1 : 0] reg_i_instruction;
    reg [CANT_BITS_ADDR - 1 : 0] reg_i_out_adder_pc;


    reg reg_i_control_write_reg;
    reg [clogb2 (CANT_REGISTROS - 1) - 1 : 0] reg_i_reg_write;
    reg [CANT_BITS_REGISTROS - 1 : 0] reg_i_data_write;

    reg reg_enable_pipeline;
    reg reg_enable_etapa;
    reg [clogb2 (CANT_REGISTROS - 1) - 1 : 0] reg_reg_read_from_debug_unit;
    reg reg_bit_branch_control_high_performance;
    reg reg_bit_burbuja_hazard;
    wire [clogb2 (CANT_REGISTROS - 1) - 1 : 0] wire_reg_rs_to_hazard;
    wire [clogb2 (CANT_REGISTROS - 1) - 1 : 0] wire_reg_rt_to_hazard;

    wire [CANT_BITS_ADDR - 1 : 0] wire_o_branch_dir;
    wire wire_o_branch_control;

    wire [CANT_BITS_ADDR - 1 : 0] wire_o_branch_dir_to_database;
    wire wire_o_branch_control_to_database;

    wire [CANT_BITS_REGISTROS - 1 : 0] wire_o_data_A;
    wire [CANT_BITS_REGISTROS - 1 : 0] wire_o_data_B;

    wire [CANT_BITS_REGISTROS - 1 : 0] wire_o_extension_signo_constante;
    wire [clogb2 (CANT_REGISTROS - 1) - 1 : 0] wire_o_reg_rs;
    wire [clogb2 (CANT_REGISTROS - 1) - 1 : 0] wire_o_reg_rt;
    wire [clogb2 (CANT_REGISTROS - 1) - 1 : 0] wire_o_reg_rd;


    wire wire_o_RegDst;
    wire wire_o_RegWrite;
    wire wire_o_ALUSrc;
    wire [CANT_BITS_ALU_OP - 1 : 0] wire_o_ALUOp;
    wire wire_o_MemRead;
    wire wire_o_MemWrite;
    wire wire_o_MemtoReg;
    wire [CANT_BITS_ALU_CONTROL - 1 : 0] wire_o_ALUCtrl;   

    wire wire_o_led;
    wire wire_halt_detected;
	wire [CANT_BITS_ADDR - 1 : 0] wire_out_adder_pc;
    wire [CANT_BITS_SELECT_BYTES_MEM_DATA - 1 : 0] wire_select_bytes_mem_datos;
    wire [CANT_BITS_REGISTROS - 1 : 0] wire_reg_data_to_debug_unit;
    wire wire_disable_for_exception_to_hazard_detection_unit;

	
	initial	begin
		reg_i_clock = 1'b0;
		reg_i_soft_reset = 1'b0; // Reset en 0. (Normal cerrado el boton del reset).
		reg_i_out_adder_pc = 0;
        reg_i_instruction = 0;
        reg_i_reg_write = 0;
        reg_i_control_write_reg = 0;
        reg_i_data_write = 4;
        reg_enable_pipeline = 1'b1;
        reg_enable_etapa = 1'b1;
        reg_bit_burbuja_hazard = 1'b0;
        reg_reg_read_from_debug_unit = 0;
        reg_bit_branch_control_high_performance = 0;

		#10 reg_i_soft_reset = 1'b1; // Desactivo la accion del reset.
        

        #50 reg_i_out_adder_pc = 5;
        #50 reg_i_instruction = 32'b00000000001000100001100000000100; //SLLV R3,R2,R1
        #50 reg_i_instruction = 32'b00000000001000100001100000100001; //ADDU R3,R1,R2
        #50 reg_i_instruction = 32'b00000010100000000000000000001000; //JR R20.
        #20 reg_enable_pipeline = 1'b0;
        #50 reg_enable_etapa = 1'b0;
        #50 reg_i_instruction = 32'b00010010100000110000000000001001; //BEQ R20,R3,9
        #50 reg_enable_etapa = 1'b1;
        #20 reg_enable_pipeline = 1'b1;
        #50 reg_i_instruction = 32'b00001000000000000000000000000111; //J 7
        #50 reg_i_instruction = 32'b10000010101000010000000000001000; //LB R1,8(R21)
        #50 reg_i_instruction = 32'b10100010101000010000000000001000; //SB R1,8(R21)
        #50 reg_i_instruction = 32'b00000011111000011000000000101010; //SLT R16,R31,R1
        #50 reg_i_instruction = 32'b00000000000000000000000000000000; //HALT.
		
        #20 reg_bit_burbuja_hazard = 1'b1;
        #10 reg_bit_burbuja_hazard = 1'b0;
        #20 reg_bit_branch_control_high_performance = 1;
        #10 reg_bit_branch_control_high_performance = 0;

		// Test 1: Prueba reset.
		#10000 reg_i_soft_reset = 1'b0; // Reset.
		#10 reg_i_soft_reset = 1'b1; // Desactivo el reset.
		
		
		#50000 $finish;
	end
	
	always #2.5 reg_i_clock=~reg_i_clock;  // Simulacion de clock.



//Modulo para pasarle los estimulos del banco de pruebas.
top_id
    #(
        .LENGTH_INSTRUCTION (LENGTH_INSTRUCTION),
        .CANT_REGISTROS (CANT_REGISTROS),
        .CANT_BITS_ADDR (CANT_BITS_ADDR),
        .CANT_BITS_REGISTROS (CANT_BITS_REGISTROS),
        .CANT_BITS_IMMEDIATE (CANT_BITS_IMMEDIATE),
        .CANT_BITS_ESPECIAL (CANT_BITS_ESPECIAL),
        .CANT_BITS_CEROS (CANT_BITS_CEROS),
        .CANT_BITS_ID_LSB (CANT_BITS_ID_LSB),
        .CANT_BITS_INSTRUCTION_INDEX_BRANCH (CANT_BITS_INSTRUCTION_INDEX_BRANCH),
        .CANT_BITS_FLAG_BRANCH (CANT_BITS_FLAG_BRANCH),
        .CANT_BITS_ALU_OP (CANT_BITS_ALU_OP),
        .CANT_BITS_ALU_CONTROL (CANT_BITS_ALU_CONTROL),
        .HALT_INSTRUCTION_TOP_ID (HALT_INSTRUCTION),
        .CANT_BITS_SELECT_BYTES_MEM_DATA (CANT_BITS_SELECT_BYTES_MEM_DATA)   
     ) 
    u_top_id_1    // Una sola instancia de este modulo.
    (
        .i_clock (reg_i_clock),
        .i_soft_reset (reg_i_soft_reset),

        .i_instruction (reg_i_instruction),
        .i_out_adder_pc (reg_i_out_adder_pc),

        .i_control_write_reg (reg_i_control_write_reg),
        .i_reg_write (reg_i_reg_write),
        .i_data_write (reg_i_data_write),
        .i_enable_pipeline (reg_enable_pipeline),
        .i_enable_etapa (reg_enable_etapa),
        .i_reg_read_from_debug_unit (reg_reg_read_from_debug_unit),
        .i_bit_branch_control_high_performance (reg_bit_branch_control_high_performance),
        .i_bit_burbuja_hazard (reg_bit_burbuja_hazard),
        .o_reg_rs_to_hazard (wire_reg_rs_to_hazard),
        .o_reg_rt_to_hazard (wire_reg_rt_to_hazard),

        .o_out_adder_pc (wire_out_adder_pc),
        .o_branch_dir (wire_o_branch_dir),
        .o_branch_control (wire_o_branch_control),
        .o_branch_dir_to_database (wire_o_branch_dir_to_database),
        .o_branch_control_to_database (wire_o_branch_control_to_database),
        .o_data_A (wire_o_data_A),
        .o_data_B (wire_o_data_B),
        .o_extension_signo_constante (wire_o_extension_signo_constante),
        .o_reg_rs (wire_o_reg_rs),
        .o_reg_rt (wire_o_reg_rt),
        .o_reg_rd (wire_o_reg_rd),
        // Control
        .o_RegDst (wire_o_RegDst),
        .o_RegWrite (wire_o_RegWrite),
        .o_ALUSrc (wire_o_ALUSrc),
        .o_ALUOp (wire_o_ALUOp),
        .o_MemRead (wire_o_MemRead),
        .o_MemWrite (wire_o_MemWrite),
        .o_MemtoReg (wire_o_MemtoReg),
        .o_ALUCtrl (wire_o_ALUCtrl),   
        .o_halt_detected (wire_halt_detected),
        .o_select_bytes_mem_datos (wire_select_bytes_mem_datos),
        .o_reg_data_to_debug_unit (wire_reg_data_to_debug_unit),
        .o_disable_for_exception_to_hazard_detection_unit (wire_disable_for_exception_to_hazard_detection_unit),
        .o_led(wire_o_led)
    );
   
endmodule

 
