`timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 2. UART.
// Test bench de la ALU.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////

`define BUS_DATOS               4   // Tamanio del bus de entrada. 
`define BUS_SALIDA              4   // Tamanio del bus de salida. 
`define CANT_BITS_OPCODE_ALU    4   // Cantidad de bits del codigo de operacion de la ALU.


module TestBenchAlu();

	// Parametros
    parameter BUS_DATOS = `BUS_DATOS;
    parameter BUS_SALIDA = `BUS_SALIDA;
    parameter CANT_BITS_OPCODE_ALU = `CANT_BITS_OPCODE_ALU;
	
	//Todo puerto de salida del modulo es un cable.
	//Todo puerto de estimulo o generacion de entrada es un registro.
	
	// Entradas - Salidas
    reg [BUS_DATOS - 1 : 0] reg_operando_1;  
    reg [BUS_DATOS - 1 : 0] reg_operando_2;           
    reg [CANT_BITS_OPCODE_ALU - 1 : 0] reg_opcode;   // Codigo de operacion.
    wire [BUS_SALIDA - 1 : 0] leds;            
	
	
	initial	begin
		#10 reg_operando_1 = 4'b00000000; 
		#10 reg_opcode = 4'b00000000;
		#10 reg_operando_2 = 4'b00000000;
		
		// Test 4: ADD.
		#50 reg_operando_1 = 4'b00001101;
        #10 reg_opcode = 4'b00100000; //ADD
        #10 reg_operando_2 = 4'b00000101;
       
		// Test 5: SUB.
		#50 reg_operando_1 = 4'b00000101;
        #10 reg_opcode = 4'b00100010; //SUB
        #10 reg_operando_2 = 4'b00000001;
       				
		// Test 6: AND.
        #50 reg_operando_1 = 4'b00001101;
        #10 reg_opcode = 4'b00100100; //AND
        #10 reg_operando_2 = 4'b00000101;
               
        // Test 7: OR.
         #50 reg_operando_1 = 4'b00000101;
         #10 reg_opcode = 4'b00100101; //OR
         #10 reg_operando_2 = 4'b00001101;
              
		
        // Test 8: XOR.
         #50 reg_operando_1 = 4'b00001101;
         #10 reg_opcode = 4'b00100110; //XOR
         #10 reg_operando_2 = 4'b00000101;
              
         
        // Test 9: SRA.
		 #50 reg_operando_1 = 4'b00000101;
         #10 reg_opcode = 4'b00000011; //SRA
         #10 reg_operando_2 = 4'b00000011;
           
		
		// Test 10: SRL.
		 #50 reg_operando_1 = 4'b00001101;
         #10 reg_opcode = 4'b00000010; //SRL
         #10 reg_operando_2 = 4'b00000011;
              
		
		// Test 11: NOR.
		 #50 reg_operando_1 = 4'b00000101;
         #10 reg_opcode = 4'b00100111; //NOR
         #10 reg_operando_2 = 4'b00000101;
          
		
		// Test 12: Operacion falsa.
         #50 reg_operando_1 = 4'b00001101;
         #10 reg_opcode = 4'b00000000; //Ninguna operacion.
         #10 reg_operando_2 = 4'b00001001;
		
		
		#1000 $finish;
	end
	
	//always #2.5 clock=~clock;  // Simulacion de clock.



// Modulo para pasarle los estimulos del banco de pruebas.
alu
    #(
         .CANT_BUS_ENTRADA (BUS_DATOS),
         .CANT_BUS_SALIDA (BUS_SALIDA),
         .CANT_BITS_OPCODE (CANT_BITS_OPCODE_ALU)
     ) 
   u_alu1    // Una sola instancia de este modulo
   (
   .i_operando_1 (reg_operando_1),
   .i_operando_2 (reg_operando_2),
   .i_opcode (reg_opcode),
   .o_resultado (leds)
   );
   
endmodule

