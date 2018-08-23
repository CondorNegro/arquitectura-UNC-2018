`timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Práctico N° 1. ALU.
// Test bench de la ALU.
// Integrantes: Kleiner Matías, López Gastón.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Año 2018.
//////////////////////////////////////////////////////////////////////////////////

`define BUS_DATOS               4   // Tamaño del bus de entrada. 
`define BUS_SALIDA              4   // Tamaño del bus de salida. 
`define CANT_BITS_OPCODE_ALU    4   // Cantidad de bits del código de operación de la ALU.

module TestBenchAlu();
	
	
	// Parámetros
    parameter BUS_DATOS = `BUS_DATOS;
    parameter BUS_SALIDA = `BUS_SALIDA;
    parameter CANT_BITS_OPCODE_ALU = `CANT_BITS_OPCODE_ALU;
	
	//Todo puerto de salida del módulo es un cable.
	//Todo puerto de estímulo o generación de entrada es un registro.
	
	// Entradas - Salidas
    reg [BUS_DATOS - 1 : 0] reg_operando_1;  
    reg [BUS_DATOS - 1 : 0] reg_operando_2;           
    reg [CANT_BITS_OPCODE_ALU - 1 : 0] reg_opcode;   
    wire [BUS_SALIDA - 1 : 0] leds;             // Leds.
	
	
	initial	begin
		#10 reg_operando_1 = 4'b0000; 
		#10 reg_opcode = 4'b0000;
		#10 reg_operando_2 = 4'b0000;
		
		// Test 4: ADD.
		#50 reg_operando_1 = 4'b1101;
        #10 reg_opcode = 4'b1000; //ADD
        #10 reg_operando_2 = 4'b0101;
       
		// Test 5: SUB.
		#50 reg_operando_1 = 4'b0101;
        #10 reg_opcode = 4'b1010; //SUB
        #10 reg_operando_2 = 4'b0001;
       				
		// Test 6: AND.
        #50 reg_operando_1 = 4'b1101;
        #10 reg_opcode = 4'b1100; //AND
        #10 reg_operando_2 = 4'b0101;
               
        // Test 7: OR.
         #50 reg_operando_1 = 4'b0101;
         #10 reg_opcode = 4'b1101; //OR
         #10 reg_operando_2 = 4'b1101;
              
		
        // Test 8: XOR.
         #50 reg_operando_1 = 4'b1101;
         #10 reg_opcode = 4'b1110; //XOR
         #10 reg_operando_2 = 4'b0101;
              
         
        // Test 9: SRA.
		 #50 reg_operando_1 = 4'b0101;
         #10 reg_opcode = 4'b0011; //SRA
         #10 reg_operando_2 = 4'b0011;
           
		
		// Test 10: SRL.
		 #50 reg_operando_1 = 4'b1101;
         #10 reg_opcode = 4'b0010; //SRL
         #10 reg_operando_2 = 4'b0011;
              
		
		// Test 11: NOR.
		 #50 reg_operando_1 = 4'b0101;
         #10 reg_opcode = 4'b1111; //NOR
         #10 reg_operando_2 = 4'b0101;
          
		
		// Test 12: Operación falsa.
         #50 reg_operando_1 = 4'b1101;
         #10 reg_opcode = 4'b0000; //Ninguna operacion.
         #10 reg_operando_2 = 4'b1101;
		
	
		
		
		#1000 $finish;
	end
	
	//always #2.5 clock=~clock;  // Simulación de clock.



//Módulo para pasarle los estímulos del banco de pruebas.
alu
    #(
         .CANT_BUS_ENTRADA (BUS_DATOS),
         .CANT_BUS_SALIDA (BUS_SALIDA),
         .CANT_BITS_OPCODE (CANT_BITS_OPCODE_ALU)
     ) 
   u_alu1    // Una sola instancia de este módulo
   (
   .i_operando_1 (reg_operando_1),
   .i_operando_2 (reg_operando_2),
   .i_opcode (reg_opcode),
   .o_resultado (leds)
   );
   
endmodule

