 `timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 2. UART.
// Interface_circuit.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////////////////////


// Constantes.
`define CANT_DATOS_ENTRADA_ALU      8       // Tamanio del bus de entrada de la ALU.
`define CANT_BITS_OPCODE_ALU        8       // Numero de bits del codigo de operacion de la ALU.
`define CANT_DATOS_SALIDA_ALU       8       // Tamanio del bus de salida de la ALU.
`define WIDTH_WORD_INTERFACE        8       // Tamanio de palabra de la trama UART.



module interface_circuit( 
   i_reset,
   i_resultado_alu,
   i_data_rx,
   i_rx_done,
   i_tx_done,
   i_clock,
   o_tx_start,
   o_data_tx,
   o_reg_dato_A,
   o_reg_dato_B,
   o_reg_opcode,
   o_prueba
   );

// Parametros.
parameter CANT_DATOS_ENTRADA_ALU    = `CANT_DATOS_ENTRADA_ALU;
parameter CANT_BITS_OPCODE_ALU      = `CANT_BITS_OPCODE_ALU;
parameter CANT_DATOS_SALIDA_ALU     = `CANT_DATOS_SALIDA_ALU;
parameter WIDTH_WORD_INTERFACE      = `WIDTH_WORD_INTERFACE;

// Local Param
localparam ESPERA = 4'b0001;
localparam OPERANDO1 = 4'b0010;
localparam OPERACION = 4'b0100;
localparam OPERANDO2 = 4'b1000;

// Entradas - Salidas.
input i_clock;
input  i_rx_done;
input  i_tx_done;
input  [CANT_DATOS_SALIDA_ALU - 1 : 0]   i_resultado_alu;
input  [WIDTH_WORD_INTERFACE - 1 : 0]  i_data_rx;
input  i_reset;  
output reg [WIDTH_WORD_INTERFACE - 1 : 0]  o_data_tx;
output reg o_tx_start;
output reg [CANT_DATOS_ENTRADA_ALU - 1 : 0] o_reg_dato_A;             
output reg [CANT_DATOS_ENTRADA_ALU - 1 : 0] o_reg_dato_B; 
output reg [CANT_BITS_OPCODE_ALU - 1 : 0] o_reg_opcode;  // Codigo de operacion.      

output reg o_prueba;

// Registros.
reg [ 3 : 0 ] reg_state;
reg [ 3 : 0 ] reg_next_state;
reg registro_tx_done;
reg registro_rx_done;

reg [CANT_DATOS_ENTRADA_ALU - 1 : 0] o_reg_dato_A_next;             
reg [CANT_DATOS_ENTRADA_ALU - 1 : 0] o_reg_dato_B_next; 
reg [CANT_BITS_OPCODE_ALU - 1 : 0] o_reg_opcode_next;  // Codigo de operacion.  
reg [WIDTH_WORD_INTERFACE - 1 : 0]  o_data_tx_next;   


always@( posedge i_clock ) begin //Memory
    // Se resetean los registros.
   if (~ i_reset) begin
       reg_state <= 1;
       registro_tx_done <= 0;
       registro_rx_done <= 0;
       o_reg_dato_A <= 0;
       o_reg_dato_B <= 0;
       o_reg_opcode <= 0;
       o_data_tx <= 0;
   end 

   else begin
       registro_tx_done <= i_tx_done;
       registro_rx_done <= i_rx_done;
       reg_state <= reg_next_state;

       o_reg_dato_A <= o_reg_dato_A_next;
       o_reg_dato_B <= o_reg_dato_B_next;
       o_reg_opcode <= o_reg_opcode_next;
       o_data_tx <= o_data_tx_next;
   end
end




always@( * ) begin //NEXT - STATE logic
   
   case (reg_state)
       
       ESPERA : begin
           if ((i_rx_done == 1) && (registro_rx_done == 0)) begin  // Deteccion de flanco ascendente
               reg_next_state = OPERANDO1;
           end
           else begin
               reg_next_state = ESPERA;
           end  
       end
       
       OPERANDO1 : begin
           if ((i_rx_done == 1) && (registro_rx_done == 0)) begin  // Deteccion de flanco ascendente
               reg_next_state = OPERACION;
           end
           else begin
               reg_next_state = OPERANDO1;
           end  
       end
       
       OPERACION : begin
          if ((i_rx_done == 1) && (registro_rx_done == 0)) begin  // Deteccion de flanco ascendente
               reg_next_state = OPERANDO2;
           end
           else begin
               reg_next_state = OPERACION;
           end  
       end
       
       OPERANDO2 : begin
           // Deteccion de flanco ascendente
           // Si se detecta que el registro_tx_done pasa de 0 a 1, se va al estado ESPERA.
           if ( (i_tx_done == 1) && (registro_tx_done == 0)) begin
               reg_next_state = ESPERA;
           end
           else begin
               reg_next_state = OPERANDO2;
           end        
       end
       
       default begin
           reg_next_state = ESPERA;
       end
   endcase 
end


always@( * ) begin //Output logic
   o_prueba = 0;
   case (reg_state)
       
       ESPERA : begin
           o_tx_start = 0;
           o_data_tx_next = o_data_tx;
           o_reg_dato_A_next = o_reg_dato_A;
           o_reg_dato_B_next = o_reg_dato_B;
           o_reg_opcode_next = o_reg_opcode;
       end
       
       OPERANDO1 : begin
           o_tx_start = 0;
           o_data_tx_next = o_data_tx;
           o_reg_dato_A_next = i_data_rx;
           o_reg_dato_B_next = o_reg_dato_B;
           o_reg_opcode_next = o_reg_opcode;
       end
       
       OPERACION : begin
           o_tx_start = 0;
           o_prueba = 1;
           o_data_tx_next = o_data_tx;
           o_reg_dato_A_next = o_reg_dato_A;
           o_reg_dato_B_next = o_reg_dato_B;
           o_reg_opcode_next = i_data_rx;
          
       end
       
       OPERANDO2 : begin
           o_tx_start = 1;
           o_prueba = 0;
           o_data_tx_next = i_resultado_alu; 
           o_reg_dato_A_next = o_reg_dato_A;
           o_reg_dato_B_next = i_data_rx;
           o_reg_opcode_next = o_reg_opcode;    
       end
       
       default : begin
           o_tx_start = 0;
           o_data_tx_next = o_data_tx;
           o_reg_dato_A_next = o_reg_dato_A;
           o_reg_dato_B_next = o_reg_dato_B;
           o_reg_opcode_next = o_reg_opcode;
       end
   
   endcase 
end

endmodule
