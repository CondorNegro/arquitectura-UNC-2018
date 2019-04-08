
 `timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Test bench del modulo control.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////


module test_bench_control();

    parameter CANT_BITS_INSTRUCTION = 32;
    parameter CANT_BITS_FLAG_BRANCH = 3;
    parameter CANT_BITS_ALU_OP = 2;
    parameter CANT_BITS_ALU_CONTROL = 4;
    parameter CANT_BITS_ESPECIAL = 6;
    parameter CANT_BITS_ID_LSB = 6;
    parameter CANT_BITS_SELECT_BYTES_MEM_DATA = 2;


    //Todo puerto de salida del modulo es un cable.
	//Todo puerto de estimulo o generacion de entrada es un registro.

	// Entradas.
    reg reg_clock;
    reg reg_soft_reset;
    reg [CANT_BITS_INSTRUCTION - 1 : 0] reg_instruction;
    reg reg_enable_etapa;
    wire wire_RegDst;
    wire wire_RegWrite;
    wire wire_ALUSrc;
    wire [CANT_BITS_ALU_OP - 1 : 0] wire_ALUOp;
    wire [CANT_BITS_ALU_CONTROL - 1 : 0] wire_ALUCtrl;
    wire wire_MemRead;
    wire wire_MemWrite;
    wire wire_MemtoReg;
    wire [CANT_BITS_SELECT_BYTES_MEM_DATA - 1 : 0] wire_select_bytes_mem_datos;  

	initial	begin
       reg_clock = 1'b0;
       reg_soft_reset = 1'b0; // Reset en 0. 
	   reg_instruction = 32'b00000000000000010001000011000000; //SLL R2,R1,3
       reg_enable_etapa = 1'b1;
       #20 reg_soft_reset = 1'b1;
       #20 reg_instruction = 32'b00000000001000100001100000000100; //SLLV R3,R2,R1
       #20 reg_enable_etapa = 1'b0;
       #20 reg_instruction = 32'b00000000001000100001100000100001; //ADDU R3,R1,R2
       #20 reg_enable_etapa = 1'b1;
       #20 reg_instruction = 32'b00000010100000000000000000001000; //JR R20.
       #20 reg_instruction = 32'b00010010100000110000000000001001; //BEQ R20,R3,9
       #20 reg_instruction = 32'b00001000000000000000000000000111; //J 7
       #20 reg_instruction = 32'b10000010101000010000000000001000; //LB R1,8(R21)
       #20 reg_instruction = 32'b10100010101000010000000000001000; //SB R1,8(R21)
       #20 reg_instruction = 32'b00000011111000011000000000101010; //SLT R16,R31,R1
       #20 reg_instruction = 32'b00000000000000000000000000000000; //HALT.
     
       // Test 4: Prueba reset.
	   #1000 reg_soft_reset = 1'b0; // Reset.
	   #1000 reg_soft_reset = 1'b1; // Desactivo el reset.


	   #500000 $finish;
	end
	
    always #2.5 reg_clock = ~reg_clock;  // Simulacion de clock.


// Modulo para pasarle los estimulos del banco de pruebas.
control 
    #(
        .CANT_BITS_INSTRUCTION (CANT_BITS_INSTRUCTION),
        .CANT_BITS_FLAG_BRANCH (CANT_BITS_FLAG_BRANCH),
        .CANT_BITS_ALU_OP (CANT_BITS_ALU_OP),
        .CANT_BITS_ESPECIAL (CANT_BITS_ESPECIAL),
        .CANT_BITS_ID_LSB (CANT_BITS_ID_LSB),
        .CANT_BITS_ALU_CONTROL (CANT_BITS_ALU_CONTROL),
        .CANT_BITS_SELECT_BYTES_MEM_DATA (CANT_BITS_SELECT_BYTES_MEM_DATA)

    )
    u_control_1
    (
        .i_clock (reg_clock),
        .i_soft_reset (reg_soft_reset),
        .i_instruction (reg_instruction),
        .i_enable_etapa (reg_enable_etapa),
        .o_RegDst (wire_RegDst),
        .o_RegWrite (wire_RegWrite),
        .o_ALUSrc (wire_ALUSrc),
        .o_ALUOp (wire_ALUOp),
        .o_ALUCtrl (wire_ALUCtrl),
        .o_MemRead (wire_MemRead),
        .o_MemWrite (wire_MemWrite),
        .o_MemtoReg (wire_MemtoReg),
        .o_select_bytes_mem_datos (wire_select_bytes_mem_datos)
    );

endmodule