`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Debug_unit.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////////////////////


module debug_unit
#(
  parameter OUTPUT_WORD_LENGTH = 8,    //  Cantidad de bits de la palabra a transmitir.
  parameter HALT_OPCODE = 0,           //  Opcode de la instruccion HALT.
  parameter ADDR_MEM_LENGTH = 11,      //  Cantidad de bits del bus de direcciones de la memoria.
  parameter CANTIDAD_ESTADOS = 5,      //  Cantidad de estados
  parameter LONGITUD_INSTRUCCION = 32  //  Cantidad de bits de la instruccion

)
(
  input i_clock,
  input i_reset,
  input i_tx_done,
  input i_rx_done,
  input [OUTPUT_WORD_LENGTH - 1 : 0] i_data_rx,
  input i_soft_reset_ack,
  output reg o_tx_start,
  output reg [OUTPUT_WORD_LENGTH - 1 : 0] o_data_tx,
  output reg o_soft_reset,
  output reg o_write_mem_programa,
  output reg [ADDR_MEM_LENGTH - 1 : 0] o_addr_mem_programa,
  output reg [LONGITUD_INSTRUCCION - 1 : 0] o_dato_mem_programa,
  output reg o_modo_ejecucion,
  output reg o_enable_mem,
  output reg o_rsta_mem,
  output reg o_regcea_mem,
  output reg o_led
 );

// Funcion para calcular el logaritmo en base 2.
function integer clogb2;
   input [31:0] value;
   begin
       value = value - 1;
       for (clogb2 = 0; value > 0; clogb2 = clogb2 + 1) begin
           value = value >> 1;
       end
   end
endfunction


// Estados
localparam ESPERA           = 5'b00001;
localparam SOFT_RESET       = 5'b00010;    
localparam ESPERA_PC_ACK    = 5'b00100;
localparam READ_PROGRAMA    = 5'b01000;
localparam ESPERA_START     = 5'b10000;

localparam CANT_BITS_CONTADOR_DATOS = clogb2 (LONGITUD_INSTRUCCION / OUTPUT_WORD_LENGTH);
//localparam CANT_BITS_DEPTH_MEM = 2 ** ADDR_MEM_LENGTH;

// Registros.
reg [ CANTIDAD_ESTADOS - 1 : 0 ] reg_state;
reg [ CANTIDAD_ESTADOS - 1 : 0 ] reg_next_state;
reg registro_rx_done;
reg [LONGITUD_INSTRUCCION - 1 : 0] reg_instruccion;
reg [CANT_BITS_CONTADOR_DATOS - 1 : 0] reg_contador_datos;
reg [ADDR_MEM_LENGTH - 1 : 0] reg_contador_addr_mem;
reg [LONGITUD_INSTRUCCION - 1 : 0] o_next_dato_mem_programa;
//reg [OUTPUT_WORD_LENGTH - 1 : 0] o_data_tx_next;

reg flag_send_mem; //Sirve para que el primer dato que se envia sea la instruccion valida y no un 1 (reg instruccion inicializa en 1)




always @ ( posedge i_clock ) begin //Memory
  // Se resetean los registros.
 if (~ i_reset) begin
     reg_state <= 1;
     registro_rx_done <= 0;
     reg_instruccion <= 1;
     reg_contador_datos <= 0;
     reg_contador_addr_mem <= 0;
     o_dato_mem_programa <= 0;
     flag_send_mem<=0;
 end

 else begin
     reg_state <= reg_next_state;
     registro_rx_done <= i_rx_done;
     o_dato_mem_programa <= o_next_dato_mem_programa;
     if (reg_state == READ_PROGRAMA) begin
       if (~i_rx_done & registro_rx_done) begin
         
         reg_instruccion <= reg_instruccion << OUTPUT_WORD_LENGTH;
         reg_instruccion [ OUTPUT_WORD_LENGTH - 1 : 0] <= i_data_rx;
         reg_contador_datos <= reg_contador_datos + 1;
         if (reg_contador_datos ==  3) begin
           reg_contador_addr_mem <= reg_contador_addr_mem + 1;
           
         end
         else begin
           reg_contador_addr_mem <= reg_contador_addr_mem;
           flag_send_mem<=1;
         end
       end
       else begin
         reg_instruccion  <= reg_instruccion;
         reg_contador_datos <= reg_contador_datos;
         reg_contador_addr_mem <= reg_contador_addr_mem;
       end
     end
     else begin
       reg_instruccion <= 1;
       reg_contador_datos <= 0;
       reg_contador_addr_mem <= 0;
     end

 end

end



always@( * ) begin //NEXT - STATE logic

 case (reg_state)

       ESPERA : begin
           if ((~i_rx_done & registro_rx_done) && (i_data_rx == 8'b00000000)) begin
               reg_next_state = SOFT_RESET;
           end
           else begin
               reg_next_state = ESPERA;
           end
       end

       SOFT_RESET : begin
           if (i_soft_reset_ack == 1'b0) begin
               reg_next_state = ESPERA_PC_ACK;
           end
           else begin
               reg_next_state = SOFT_RESET;
           end
       end

       ESPERA_PC_ACK : begin
           if ((~i_rx_done & registro_rx_done) && (i_data_rx == 8'b00000001)) begin
               reg_next_state = READ_PROGRAMA;
           end
           else begin
               reg_next_state = ESPERA_PC_ACK;
           end
       end

       READ_PROGRAMA : begin
           if ((reg_instruccion == { LONGITUD_INSTRUCCION {1'b0} }) && (flag_send_mem == 1) && (reg_contador_datos ==  0) ) begin
               reg_next_state = ESPERA_START;
           end
           else begin
               reg_next_state = READ_PROGRAMA;
           end
       end
       ESPERA_START : begin
           if ((~i_rx_done & registro_rx_done) && ((i_data_rx == 8'b00000011) || (i_data_rx == 8'b00000111))) begin
               reg_next_state = ESPERA;
           end
           else begin
               reg_next_state = ESPERA_START;
           end
       end

       default begin
           reg_next_state = ESPERA;
       end
 endcase
end


always @ ( * ) begin //Output logic
 case (reg_state)

       ESPERA : begin
         o_tx_start = 0;
         o_data_tx = 0;
         o_soft_reset = 1; //Logica por nivel bajo.
         o_write_mem_programa = 0; //Write es en 1.
         o_addr_mem_programa = 0;
         o_next_dato_mem_programa = 0;
         o_modo_ejecucion = 0; // Continuo.
         o_enable_mem = 0;
         o_rsta_mem = 1;
         o_regcea_mem = 1;
         o_led = 1;
       end

       SOFT_RESET : begin
         o_tx_start = 0;
         o_data_tx = 0;
         o_soft_reset = 0; //Logica por nivel bajo.
         o_write_mem_programa = 0; //Write es en 1.
         o_addr_mem_programa = 0;
         o_next_dato_mem_programa = 0;
         o_modo_ejecucion = 0; // Continuo.
         o_enable_mem = 1;
         o_rsta_mem = 0;
         o_regcea_mem = 0;
         o_led = 0;
       end

       ESPERA_PC_ACK : begin
         o_tx_start = 1;
         o_data_tx = 8'b00000001;
         o_soft_reset = 1; //Logica por nivel bajo.
         o_write_mem_programa = 0; //Write es en 1.
         o_addr_mem_programa = 0;
         o_next_dato_mem_programa = 0;
         o_modo_ejecucion = 0; // Continuo.
         o_enable_mem = 1;
         o_rsta_mem = 0;
         o_regcea_mem = 0;
         o_led = 0; 
       end

//{ CANT_BITS_CONTADOR_DATOS {1'b1} }
       READ_PROGRAMA : begin
         o_tx_start = 0;
         o_data_tx = 0;
         o_soft_reset = 1; //Logica por nivel bajo.
         o_write_mem_programa = 1; //Write es en 1.
         o_addr_mem_programa = reg_contador_addr_mem;
         if (reg_contador_datos ==  0 && flag_send_mem==1) begin
           o_next_dato_mem_programa = reg_instruccion;
         end
         else begin
           o_next_dato_mem_programa = o_dato_mem_programa;
         end
         o_modo_ejecucion = 0; // Continuo.
         o_enable_mem = 1;
         o_rsta_mem = 0;
         o_regcea_mem = 0; 
         o_led = 0;
       end

       ESPERA_START : begin
         o_tx_start = 0;
         o_data_tx = 0;
         o_soft_reset = 1; //Logica por nivel bajo.
         o_write_mem_programa = 0; //Write es en 1.
         o_addr_mem_programa = 0;
         o_next_dato_mem_programa = 0;
         o_modo_ejecucion = i_data_rx [2];// Continuo en cero, paso a paso en 1.
         o_enable_mem = 1;
         o_rsta_mem = 0;
         o_regcea_mem = 0;
         o_led = 0;
       end

       default : begin
         o_tx_start = 0;
         o_data_tx = 0;
         o_soft_reset = 1; //Logica por nivel bajo.
         o_write_mem_programa = 0; //Write es en 1.
         o_addr_mem_programa = 0;
         o_next_dato_mem_programa = 0;
         o_modo_ejecucion = 0; // Continuo.
         o_enable_mem = 0;
         o_rsta_mem = 1;
         o_regcea_mem = 1;
         o_led = 1;
       end

 endcase
end

endmodule
