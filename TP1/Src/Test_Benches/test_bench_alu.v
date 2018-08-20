`timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Práctico N° 1. ALU.
// Test bench de la ALU.
// Integrantes: Kleiner Matías, López Gastón.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Año 2018.
//////////////////////////////////////////////////////////////////////////////////

`define BUS_DATOS           6   // Tamaño del bus de entrada. (Por ejemplo, cantidad de switches).
`define BUS_SALIDA          6   // Tamaño del bus de salida. (Por ejemplo, cantidad de leds).
`define CANT_BOTONES_ALU    4   // Cantidad de botones.

module TestBenchAlu();
	
	
	// Parámetros
    parameter BUS_DATOS = `BUS_DATOS;
    parameter BUS_SALIDA = `BUS_SALIDA;
    parameter CANT_BOTONES_ALU = `CANT_BOTONES_ALU;
	
	//Todo puerto de salida del módulo es un cable.
	//Todo puerto de estímulo o generación de entrada es un registro.
	
	// Entradas - Salidas
    reg clock;                                  // Clock.
    reg hard_reset;                             // Reset.
    reg [BUS_DATOS - 1 : 0] switches;           // Switches.
    reg [CANT_BOTONES_ALU - 1 : 0] botones;     // Botones.
    wire [BUS_SALIDA - 1 : 0] leds;             // Leds.
	
	
	initial	begin
		clock = 1'b0;
		hard_reset = 1'b1; // Reset en 1.
		switches = 6'b000000; 
		botones = 4'b0000;
		#10 hard_reset = 1'b0; // Bajo el reset.
		
		// Test 1: cargar primer operando.
		#10 botones[0] = 1'b1;
		#10 switches = 6'b010101;
		#10 botones[0] = 1'b0;
		
		// Test 2: cargar segundo operando.
		#10 botones[1] = 1'b1;
        #10 switches = 6'b100000; //ADD
        #10 botones[1] = 1'b0;
		
		// Test 3: cargar tercer operando.
		#10 botones[2] = 1'b1;
        #10 switches = 6'b010101;
        #10 botones[2] = 1'b0;
		
		
		// Test 4: ADD.
		#50 botones[0] = 1'b1;
        #10 switches = 6'b110101;
        #10 botones[0] = 1'b0;
        #10 botones[1] = 1'b1;
        #10 switches = 6'b100000; //ADD
        #10 botones[1] = 1'b0;
        #10 botones[2] = 1'b1;
        #10 switches = 6'b000101;
        #10 botones[2] = 1'b0;
		
		
		// Test 5: SUB.
		#50 botones[0] = 1'b1;
        #10 switches = 6'b010101;
        #10 botones[0] = 1'b0;
        #10 botones[1] = 1'b1;
        #10 switches = 6'b100010; //SUB
        #10 botones[1] = 1'b0;
        #10 botones[2] = 1'b1;
        #10 switches = 6'b000101;
        #10 botones[2] = 1'b0;
		
		
		// Test 6: AND.
        #50 botones[0] = 1'b1;
        #10 switches = 6'b110101;
        #10 botones[0] = 1'b0;
        #10 botones[1] = 1'b1;
        #10 switches = 6'b100100; //AND
        #10 botones[1] = 1'b0;
        #10 botones[2] = 1'b1;
        #10 switches = 6'b000101;
        #10 botones[2] = 1'b0;        
        
        
        // Test 7: OR.
         #50 botones[0] = 1'b1;
         #10 switches = 6'b110101;
         #10 botones[0] = 1'b0;
         #10 botones[1] = 1'b1;
         #10 switches = 6'b100101; //OR
         #10 botones[1] = 1'b0;
         #10 botones[2] = 1'b1;
         #10 switches = 6'b000101;
         #10 botones[2] = 1'b0;       
		
        // Test 8: XOR.
         #50 botones[0] = 1'b1;
         #10 switches = 6'b110101;
         #10 botones[0] = 1'b0;
         #10 botones[1] = 1'b1;
         #10 switches = 6'b100110; //XOR
         #10 botones[1] = 1'b0;
         #10 botones[2] = 1'b1;
         #10 switches = 6'b000101;
         #10 botones[2] = 1'b0;       
          
                
        // Test 9: SRA.
		 #50 botones[0] = 1'b1;
         #10 switches = 6'b110101;
         #10 botones[0] = 1'b0;
         #10 botones[1] = 1'b1;
         #10 switches = 6'b000011; //SRA
         #10 botones[1] = 1'b0;
         #10 botones[2] = 1'b1;
         #10 switches = 6'b000011;
         #10 botones[2] = 1'b0;       
		
		// Test 10: SRL.
		 #50 botones[0] = 1'b1;
         #10 switches = 6'b110101;
         #10 botones[0] = 1'b0;
         #10 botones[1] = 1'b1;
         #10 switches = 6'b000010; //SRL
         #10 botones[1] = 1'b0;
         #10 botones[2] = 1'b1;
         #10 switches = 6'b000011;
         #10 botones[2] = 1'b0;       
		
		// Test 11: NOR.
		 #50 botones[0] = 1'b1;
         #10 switches = 6'b110101;
         #10 botones[0] = 1'b0;
         #10 botones[1] = 1'b1;
         #10 switches = 6'b100111; //NOR
         #10 botones[1] = 1'b0;
         #10 botones[2] = 1'b1;
         #10 switches = 6'b000101;
         #10 botones[2] = 1'b0;       
		
		// Test 12: Operación falsa.
        #50 botones[0] = 1'b1;
        #10 switches = 6'b110101;
        #10 botones[0] = 1'b0;
        #10 botones[1] = 1'b1;
        #10 switches = 6'b111111; //Falsa.
        #10 botones[1] = 1'b0;
        #10 botones[2] = 1'b1;
        #10 switches = 6'b000101;
        #10 botones[2] = 1'b0;      
		
		// Test 13: Prueba reset.
		#100 hard_reset = 1'b1; // Reset.
		#10 hard_reset = 1'b0; // Bajo el reset.
		
		
		#1000000000 $finish;
	end
	
	always #2.5 clock=~clock;  // Simulación de clock.



//Módulo para pasarle los estímulos del banco de pruebas.
alu
    #(
         .CANT_SWITCHES (BUS_DATOS),
         .CANT_LEDS (BUS_SALIDA),
         .CANT_BOTONES (CANT_BOTONES_ALU)
     ) 
   u_alu1    // Una sola instancia de este módulo
   (
   .i_clock (clock),
   .i_reset (hard_reset),
   .i_switch (switches),
   .i_enable (botones),
   .o_leds (leds)
   );
   
endmodule

