
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
    parameter CANT_BITS_CONTROL = 4;
    parameter CANT_BITS_REGISTROS = 32;
    parameter CANT_BITS_ALU_OP = 2;
    parameter CANT_BITS_ALU_CONTROL = 4;
    parameter CANT_REGISTROS = 32;
    
    //Todo puerto de salida del modulo es un cable.
	//Todo puerto de estimulo o generacion de entrada es un registro.

	// Entradas.
    reg clock;                                  // Clock.
    reg soft_reset;                             // Reset.
    reg [CANT_BITS_CONTROL - 1 : 0] control;

    // Intruction Fetch.
    reg [ADDR_LENGTH - 1 : 0] pc;
    reg [ADDR_LENGTH - 1 : 0] adder_pc;
    reg [LONGITUD_INSTRUCCION - 1 : 0] instruction_fetch;

    reg [ADDR_LENGTH - 1 : 0] contador_ciclos;

    // Instruction decode.

    reg [ADDR_LENGTH - 1 : 0] reg_branch_dir;
    reg reg_branch_control;

    reg [CANT_BITS_REGISTROS - 1 : 0] reg_data_A;
    reg [CANT_BITS_REGISTROS - 1 : 0] reg_data_B;

    reg [CANT_BITS_REGISTROS - 1 : 0] reg_extension_signo_constante;
    reg [clogb2 (CANT_REGISTROS - 1) - 1 : 0] reg_rs;
    reg [clogb2 (CANT_REGISTROS - 1) - 1 : 0] reg_rt;
    reg [clogb2 (CANT_REGISTROS - 1) - 1 : 0] reg_rd;
       
    // Control de instruction decode.

    reg reg_RegDst;
    reg reg_RegWrite;
    reg reg_ALUSrc;
    reg [CANT_BITS_ALU_OP - 1 : 0] reg_ALUOp;
    reg reg_MemRead;
    reg reg_MemWrite;
    reg reg_MemtoReg;
    reg [CANT_BITS_ALU_CONTROL - 1 : 0] reg_ALUCtrl;


    wire [LONGITUD_INSTRUCCION - 1 : 0] wire_dato;
    
    //  The following function calculates the address width based on specified RAM depth
    function integer clogb2;
        input integer depth;
            for (clogb2=0; depth>0; clogb2=clogb2+1)
                depth = depth >> 1;
    endfunction

	initial	begin
	    clock = 1'b0;
	    soft_reset = 1'b1; // Reset en 0. (Normal cerrado el boton del reset).
	    control = 0;
	    pc = 4;
		adder_pc = 8;
		instruction_fetch = 2;
        contador_ciclos = 1;
        reg_branch_dir = 1;
        reg_branch_control = 1;
        reg_data_A = 2;
        reg_data_B = 3; 
        reg_extension_signo_constante = 4;
        reg_rs = 5;
        reg_rt = 6;
        reg_rd = 7;
        reg_RegDst = 1;
        reg_RegWrite = 0;
        reg_ALUSrc = 0;
        reg_ALUOp = 2;
        reg_MemRead = 0;
        reg_MemWrite = 1;
        reg_MemtoReg = 0;
        
        reg_ALUCtrl = 0;


	   
		#10 soft_reset = 1'b0; // Desactivo la accion del reset.
	    #10 soft_reset = 1'b1; // Desactivo la accion del reset.
	   
		#10 control = 1;
	  
		#20 control = 3;

		#20 control = 6;

        #20 control = 7;

		#20 control = 8;

        #20 control = 9;

		#20 control = 11;


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
		.CANT_BITS_CONTROL (CANT_BITS_CONTROL),
        .CANT_BITS_REGISTROS (CANT_BITS_REGISTROS),
        .CANT_BITS_ALU_OP (CANT_BITS_ALU_OP),
        .CANT_BITS_ALU_CONTROL (CANT_BITS_ALU_CONTROL),
        .CANT_REGISTROS (CANT_REGISTROS)

     )
    u_database_1
    (
        .i_clock (clock),
        .i_soft_reset (soft_reset),
        .i_control (control),
        .i_pc (pc),
		.i_adder_pc (adder_pc),
		.i_instruction_fetch (instruction_fetch),
        .i_contador_ciclos (contador_ciclos),
        .i_branch_dir (reg_branch_dir),
        .i_branch_control (reg_branch_control),
        .i_data_A (reg_data_A),
        .i_data_B (reg_data_B),
        .i_extension_signo_constante (reg_extension_signo_constante),
        .i_reg_rs (reg_rs),
        .i_reg_rt (reg_rt),
        .i_reg_rd (reg_rd),
        .i_RegDst (reg_RegDst),
        .i_RegWrite (reg_RegWrite),
        .i_ALUSrc (reg_ALUSrc),
        .i_ALUOp (reg_ALUOp),
        .i_MemRead (reg_MemRead),
        .i_MemWrite (reg_MemWrite),
        .i_MemtoReg (reg_MemtoReg),
        .i_ALUCtrl (reg_ALUCtrl),
        .o_dato (wire_dato)
    );

endmodule
