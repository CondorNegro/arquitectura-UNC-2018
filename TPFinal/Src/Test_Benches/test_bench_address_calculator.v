 `timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Test bench del modulo branch_address_calculator.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////


module test_bench_branch_address_calculator();
		
	// Parametros
    parameter CANT_BITS_ADDR = 11;
    parameter CANT_BITS_IMMEDIATE = 16;
    parameter CANT_BITS_INSTRUCTION_INDEX_BRANCH = 26;
    parameter CANT_BITS_FLAG_BRANCH = 3;
    parameter CANT_BITS_REGISTROS = 32; 
	
	//Todo puerto de salida del modulo es un cable.
	//Todo puerto de estimulo o generacion de entrada es un registro.
	
	// Entradas.
    reg [CANT_BITS_FLAG_BRANCH - 1 : 0] reg_i_flag_branch;
    reg [CANT_BITS_ADDR - 1 : 0] reg_i_adder_pc;
    reg [CANT_BITS_IMMEDIATE - 1 : 0] reg_i_immediate_address;
    reg [CANT_BITS_INSTRUCTION_INDEX_BRANCH - 1 : 0] reg_i_instruction_index_branch;
    reg [CANT_BITS_REGISTROS - 1 : 0] reg_i_dato_reg_A;
    reg [CANT_BITS_REGISTROS - 1 : 0] reg_i_dato_reg_B;
    wire wire_o_branch_control;
    wire [CANT_BITS_ADDR - 1 : 0] wire_o_branch_dir;
	
    reg clock; // unicamente como referencia
	
	initial	begin
		clock = 1'b0;
		reg_i_adder_pc = 1;
        reg_i_immediate_address = 0;
        reg_i_instruction_index_branch = 0;
        reg_i_dato_reg_A = 7;
        reg_i_dato_reg_B = 5;
        
        #20 reg_i_flag_branch = 0; //salida esperada : 
                                   //o_branch_control = 1'b0;
                                   //o_branch_dir = 1;


        #20 reg_i_flag_branch = 1; //salida esperada : 
                                   //o_branch_control = 1'b1;
                                   //o_branch_dir = 7;


        #20 reg_i_flag_branch = 2; //salida esperada : 
                                   //o_branch_control = 1'b1;
                                   //o_branch_dir = 7;


        #20 reg_i_flag_branch = 3; //salida esperada : 
                                   //o_branch_control = 1'b0;
                                   //o_branch_dir = 1;

        #20 reg_i_dato_reg_B = 7;
                                   //salida esperada : 
                                   //o_branch_control = 1'b1;
                                   //o_branch_dir = 1;


        #20 reg_i_flag_branch = 4; //salida esperada : 
                                   //o_branch_control = 1'b0;
                                   //o_branch_dir = 1;

        #20 reg_i_dato_reg_B = 5;
                                   //salida esperada : 
                                   //o_branch_control = 1'b1;
                                   //o_branch_dir = 1;


        #20 reg_i_flag_branch = 5; //salida esperada : 
                                   //o_branch_control = 1'b1;
                                   //o_branch_dir =  0;
                            
         #20 reg_i_flag_branch = 6; //salida esperada : pruebo default
                                   //o_branch_control = 1'b0;
                                   //o_branch_dir =  1;

		
		#5000 $finish;
	end
	
	always #2.5 clock=~clock;  // Simulacion de clock.



//Modulo para pasarle los estimulos del banco de pruebas.
branch_address_calculator
    #(
        .CANT_BITS_ADDR (CANT_BITS_ADDR),
        .CANT_BITS_IMMEDIATE (CANT_BITS_IMMEDIATE),
        .CANT_BITS_INSTRUCTION_INDEX_BRANCH (CANT_BITS_INSTRUCTION_INDEX_BRANCH),
        .CANT_BITS_FLAG_BRANCH (CANT_BITS_FLAG_BRANCH),
        .CANT_BITS_REGISTROS (CANT_BITS_REGISTROS)
     ) 
    u_branch_address_calculator_1    // Una sola instancia de este modulo.
    (
        .i_flag_branch (reg_i_flag_branch),
        .i_adder_pc (reg_i_adder_pc),
        .i_immediate_address (reg_i_immediate_address),
        .i_instruction_index_branch (reg_i_instruction_index_branch),
        .i_dato_reg_A (reg_i_dato_reg_A),
        .i_dato_reg_B (reg_i_dato_reg_B),
        .o_branch_control (wire_o_branch_control),
        .o_branch_dir (wire_o_branch_dir)
    );
   
endmodule

 
