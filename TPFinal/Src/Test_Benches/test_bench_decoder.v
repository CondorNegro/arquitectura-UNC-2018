`timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 3. BIP I.
// Test bench del modulo instruction_decoder.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////

module test_bench_instruction_decoder();
		
	// Parametros
    parameter OPCODE_LENGTH = 5;    // Cantidad de bits del opcode.
	
	//Todo puerto de salida del modulo es un cable.
	//Todo puerto de estimulo o generacion de entrada es un registro.
	
	// Entradas.
    reg [OPCODE_LENGTH - 1 : 0] reg_i_opcode;
    
    //salidas                            
    wire wire_o_wrPC;
    wire wire_o_wrACC;
    wire wire_o_selA;
    wire wire_o_selB;
    wire [OPCODE_LENGTH - 1 : 0] wire_o_opcode;  
    wire wire_o_wrRAM;
    wire wire_o_rdRAM;
    
    
    
	
	
	initial	begin
        reg_i_opcode = 5'b00000;
		
		#100 reg_i_opcode = 5'b00001;
		#100 reg_i_opcode = 5'b00010;
		#100 reg_i_opcode = 5'b00011;
		#100 reg_i_opcode = 5'b00100;
		#100 reg_i_opcode = 5'b00101;
		#100 reg_i_opcode = 5'b00110; 
		
		
		#500000 $finish;
	end



// Modulo para pasarle los estimulos del banco de pruebas.
instruction_decoder
    #(
         .OPCODE_LENGTH (OPCODE_LENGTH)
     ) 
    u_instruction_decoder_1    
    (
      .i_opcode (reg_i_opcode),
      .o_wrPC (wire_o_wrPC),
      .o_wrACC (wire_o_wrACC),
      .o_selA (wire_o_selA),
      .o_selB (wire_o_selB),
      .o_opcode (wire_o_opcode),
      .o_wrRAM(wire_o_wrRAM),
      .o_rdRAM(wire_o_rdRAM)
    );
   
endmodule

 
 
