
 `timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Test bench del modulo decoder.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////


module test_bench_decoder();

    parameter CANT_BITS_INSTRUCCION = 32;
    parameter CANT_BITS_ADDRESS_REGISTROS = 5;
    parameter CANT_BITS_IMMEDIATE = 16;
    parameter CANT_BITS_ESPECIAL = 6;
    parameter CANT_BITS_CEROS = 5;
    parameter CANT_BITS_ID_LSB = 6;
    parameter CANT_BITS_INSTRUCTION_INDEX_BRANCH = 26;
    parameter CANT_BITS_FLAG_BRANCH = 3; 


    //Todo puerto de salida del modulo es un cable.
	//Todo puerto de estimulo o generacion de entrada es un registro.

	// Entradas.
    reg [CANT_BITS_INSTRUCCION - 1 : 0] reg_instruction;
    wire [CANT_BITS_ADDRESS_REGISTROS - 1 : 0] wire_A;
    wire [CANT_BITS_ADDRESS_REGISTROS - 1 : 0] wire_B;
    wire [CANT_BITS_ADDRESS_REGISTROS - 1 : 0] wire_W;
    wire [CANT_BITS_FLAG_BRANCH - 1 : 0] wire_flag_branch; 
    wire [CANT_BITS_IMMEDIATE - 1 : 0] wire_immediate;
    wire [CANT_BITS_INSTRUCTION_INDEX_BRANCH - 1 : 0] wire_instruction_index_branch;

	initial	begin
	   reg_instruction = 2;
       
       #20 reg_instruction = 32'b00000000000000010001000011000000; //SLL R2,R1,3
       #20 reg_instruction = 32'b00000000001000100001100000000100; //SLLV R3,R2,R1
       #20 reg_instruction = 32'b00000000001000100001100000100001; //ADDU R3,R1,R2
       #20 reg_instruction = 32'b00000010100000000000000000001000; //JR R20.
       #20 reg_instruction = 32'b00010010100000110000000000001001; //BEQ R20,R3,9
       #20 reg_instruction = 32'b00001000000000000000000000000111; //J 7
       #20 reg_instruction = 32'b10000010101000010000000000001000; //LB R1,8(R21)
       #20 reg_instruction = 32'b00000000000000000000000000000000; // HALT.
     

	   #500000 $finish;
	end

	


// Modulo para pasarle los estimulos del banco de pruebas.
decoder
    #(
        .CANT_BITS_INSTRUCCION (CANT_BITS_INSTRUCCION),
        .CANT_BITS_ADDRESS_REGISTROS (CANT_BITS_ADDRESS_REGISTROS),
        .CANT_BITS_IMMEDIATE (CANT_BITS_IMMEDIATE),
        .CANT_BITS_ESPECIAL (CANT_BITS_ESPECIAL),
        .CANT_BITS_CEROS (CANT_BITS_CEROS),
        .CANT_BITS_ID_LSB (CANT_BITS_ID_LSB),
        .CANT_BITS_INSTRUCTION_INDEX_BRANCH (CANT_BITS_INSTRUCTION_INDEX_BRANCH),
        .CANT_BITS_FLAG_BRANCH (CANT_BITS_FLAG_BRANCH)
    )
    u_decoder_1
    (
        .i_instruction (reg_instruction),
        .o_reg_A (wire_A),
        .o_reg_B (wire_B),
        .o_reg_W (wire_W),
        .o_flag_branch (wire_flag_branch),
        .o_immediate (wire_immediate),
        .o_instruction_index_branch (wire_instruction_index_branch)
    );

endmodule