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
   o_reg_opcode
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



// Registros.
reg [ 3 : 0 ] reg_state;
reg [ 3 : 0 ] reg_next_state;


always@( posedge i_clock ) begin //Memory
    // Se resetean los registros.
   if (~ i_reset) begin
       reg_state <= 1;
       reg_next_state <= 1;
       o_reg_dato_A <= 0;
       o_reg_dato_B <= 0;
       o_reg_opcode <= 0;
       o_tx_start <= 0;
       o_data_tx <= 0;
   end 

   else begin
       reg_state <= reg_next_state;
       reg_next_state <= reg_next_state;
       o_reg_dato_A <= o_reg_dato_A;
       o_reg_dato_B <= o_reg_dato_B;
       o_reg_opcode <= o_reg_opcode;
       o_tx_start <= o_tx_start;
       o_data_tx <= o_data_tx;       
   end
end




always@( i_rx_done, i_tx_done ) begin //NEXT - STATE logic
   
   case (reg_state)
       
       ESPERA : begin
           if (i_rx_done == 1) begin
               reg_next_state = OPERANDO1;
           end
           else begin
               reg_next_state = ESPERA;
           end  
       end
       
       OPERANDO1 : begin
           if (i_rx_done == 1) begin
               reg_next_state = OPERACION;
           end
           else begin
               reg_next_state = OPERANDO1;
           end  
       end
       
       OPERACION : begin
          if (i_rx_done == 1) begin
               reg_next_state = OPERANDO2;
           end
           else begin
               reg_next_state = OPERACION;
           end  
       end
       
       OPERANDO2 : begin
           if (i_tx_done == 1) begin
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
   
   case (reg_state)
       
       ESPERA : begin
           o_tx_start = 0;
           o_data_tx = o_data_tx;
           o_reg_dato_A = o_reg_dato_A;
           o_reg_dato_B = o_reg_dato_B;
           o_reg_opcode = o_reg_opcode;
       end
       
       OPERANDO1 : begin
           o_tx_start = 0;
           o_data_tx = o_data_tx;
           o_reg_dato_A = i_data_rx;
           o_reg_dato_B = o_reg_dato_B;
           o_reg_opcode = o_reg_opcode;
       end
       
       OPERACION : begin
           o_tx_start = 0;
           o_data_tx = o_data_tx;
           o_reg_dato_A = o_reg_dato_A;
           o_reg_dato_B = o_reg_dato_B;
           o_reg_opcode = i_data_rx;
       end
       
       OPERANDO2 : begin
           o_tx_start = 1;
           o_data_tx = i_resultado_alu; 
           o_reg_dato_A = o_reg_dato_A;
           o_reg_dato_B = i_data_rx;
           o_reg_opcode = o_reg_opcode;    
       end
       
       default : begin
           o_tx_start = 0;
           o_data_tx = o_data_tx;
           o_reg_dato_A = o_reg_dato_A;
           o_reg_dato_B = o_reg_dato_B;
           o_reg_opcode = o_reg_opcode;
       end
   
   endcase 
end

endmodule
