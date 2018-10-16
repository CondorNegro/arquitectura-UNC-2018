 `timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 3. BIP I.
// Test bench del modulo datapath.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////



module test_bench_datapath();
		
	
	//Todo puerto de salida del modulo es un cable.
	//Todo puerto de estimulo o generacion de entrada es un registro.
	
	parameter OPERANDO_LENGTH = 11;         // Cantidad de bits del operando.
  	parameter OPERANDO_FINAL_LENGHT = 16;   // Cantidad de bits del operando con extension de signo.
  	parameter OPCODE_LENGTH = 5;             // Cantidad de bits del opcode.


	// Entradas.
    reg reg_reset;
	reg reg_clock;
	reg [1 : 0] reg_selA;
	reg reg_selB;
	reg reg_wrACC;
	reg [OPCODE_LENGTH - 1 : 0] reg_i_opcode;
	reg [OPERANDO_LENGTH - 1 : 0] reg_operando;
	reg [OPERANDO_FINAL_LENGHT - 1 : 0] reg_dato_mem;                      
    
	// Salidas.
	wire [OPERANDO_LENGTH - 1 : 0] wire_addr_mem_datos;
	wire [OPERANDO_FINAL_LENGHT - 1 : 0] wire_valor_ACC;
	
	
	initial	begin
		reg_clock = 1'b0;
		reg_reset = 1'b0; // Reset en 0. (Normal cerrado el boton del reset).
		reg_selA = 2'b10;
		reg_selB = 1'b1;
		reg_wrACC = 1'b1;
		reg_i_opcode = 5'b00101; // ADDI
		reg_dato_mem = 2;
		reg_operando = 3;
		#10 reg_reset = 1'b1; // Desactivo la accion del reset.
		
		// Test: Prueba reset.
		#500000 reg_reset = 1'b0; // Reset.
		#10 reg_reset = 1'b1; // Desactivo el reset.

		
        #10 reg_wrACC = 1;
        #10 reg_selA = 0;
        #10 reg_selB = 0;
        #10 reg_i_opcode = 2; //Load variable.
        
		#100 reg_reset = 1'b0; // Reset.
		#10 reg_reset = 1'b1; // Desactivo el reset.

		#1000000 $finish;
	end
	
	always #2.5 reg_clock = ~reg_clock;  // Simulacion de clock.



//Modulo para pasarle los estimulos del banco de pruebas.
datapath
   #(
	   .OPCODE_LENGTH (OPCODE_LENGTH),
	   .OPERANDO_LENGTH (OPERANDO_LENGTH),
	   .OPERANDO_FINAL_LENGHT (OPERANDO_FINAL_LENGHT)
    )
    u_datapath1
    (
        .i_clock (reg_clock),
        .i_reset (reg_reset),
        .i_selA (reg_selA),
        .i_selB (reg_selB),
        .i_wrACC (reg_wrACC),
        .i_opcode (reg_i_opcode),
        .i_operando (reg_operando),
        .i_outmemdata (reg_dato_mem),
        .o_addr (wire_addr_mem_datos),
        .o_ACC (wire_valor_ACC)            
    );
   
endmodule

 
