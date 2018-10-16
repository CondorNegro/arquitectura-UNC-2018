 `timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 3. BIP I.
// Test bench del modulo interface_circuit.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////



module test_bench_interface_circuit();
		
	// Parametros
    parameter CANT_BITS_OPCODE = 5;      //  Cantidad de bits del opcode.
    parameter CC_LENGTH = 11;            //  Cantidad de bits del contador de ciclos.
    parameter ACC_LENGTH = 16;           //  Cantidad de bits del acumulador.
    parameter OUTPUT_WORD_LENGTH = 8;    //  Cantidad de bits de la palabra a transmitir.
    parameter HALT_OPCODE = 0;            //  Opcode de la instruccion HALT.
	
	//Todo puerto de salida del modulo es un cable.
	//Todo puerto de estimulo o generacion de entrada es un registro.
	
	// Entradas.
    reg reg_reset;
	reg [CC_LENGTH - 1 : 0] reg_i_CC;
	reg [ACC_LENGTH - 1 : 0] reg_i_ACC;
	reg [CANT_BITS_OPCODE - 1 : 0] reg_i_opcode;
	
	reg [OUTPUT_WORD_LENGTH - 1 : 0] reg_data_rx;
	reg reg_rx_done;                     
    reg reg_tx_done;
	reg reg_clock;
	                       
    
	// Salidas.
	wire wire_tx_start;

	wire wire_soft_reset;
    wire [OUTPUT_WORD_LENGTH - 1 : 0] wire_data_tx;
	
	
	initial	begin
		reg_clock = 1'b0;
		reg_reset = 1'b0; // Reset en 0. (Normal cerrado el boton del reset).
		reg_data_rx = 1;
		reg_i_opcode = 1'b1;
		reg_i_CC = 16'b1100001011;
		reg_i_ACC = 16'b1000001010;
		reg_rx_done = 1'b0;
		reg_tx_done = 1'b0;
		#10 reg_reset = 1'b1; // Desactivo la accion del reset.
		
		#1000 reg_rx_done = 1'b1;
        #1000 reg_rx_done = 1'b0;
		
		#100 reg_data_rx = 2;
		
		
		#1000 reg_rx_done = 1'b1;
		#1000 reg_rx_done = 1'b0;
		
		#100 reg_i_opcode = 1'b0; //HALT - paso a estado 1

		#100 reg_tx_done = 1'b1; // paso a estado 2
		#100 reg_tx_done = 1'b0;
		
		#100 reg_tx_done = 1'b1; // paso a estado 3
        #100 reg_tx_done = 1'b0;
                
        #100 reg_tx_done = 1'b1; // paso a estado 4
        #100 reg_tx_done = 1'b0;
        
        #100 reg_tx_done = 1'b1; // paso a estado 5
        #100 reg_tx_done = 1'b0;
        
        #100 reg_tx_done = 1'b1; // Prueba del ultimo estado
        #100 reg_tx_done = 1'b0;
		
		

		// Test 5: Prueba reset.
		#500000 reg_reset = 1'b0; // Reset.
		#10 reg_reset = 1'b1; // Desactivo el reset.

		#1000000 $finish;
	end
	
	always #2.5 reg_clock = ~reg_clock;  // Simulacion de clock.



//Modulo para pasarle los estimulos del banco de pruebas.
interface_circuit
    #(
         .CANT_BITS_OPCODE (CANT_BITS_OPCODE),
         .CC_LENGTH (CC_LENGTH),
		 .ACC_LENGTH (ACC_LENGTH),
		 .OUTPUT_WORD_LENGTH (OUTPUT_WORD_LENGTH),
		 .HALT_OPCODE (HALT_OPCODE)
     ) 
    u_interface_circuit_1    // Una sola instancia de este modulo.
    (
      	.i_clock (reg_clock),
      	.i_reset (reg_reset),
      	.i_tx_done (reg_tx_done),
      	.i_rx_done (reg_rx_done),
      	.i_data_rx (reg_data_rx),
        .i_opcode(reg_i_opcode),
        .i_CC(reg_i_CC),
        .i_ACC(reg_i_ACC),
		.o_tx_start (wire_tx_start),
		.o_data_tx (wire_data_tx),
		.o_soft_reset (wire_soft_reset)
    );
   
endmodule

 
