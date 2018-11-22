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
  parameter HALT_OPCODE = 0,            //  Opcode de la instruccion HALT.
  parameter DATO_MEM_LENGTH = 8,            //  .
  parameter ADDR_MEM_LENGTH = 11,            //  .
  parameter CANTIDAD_ESTADOS = 4,
  parameter LONGITUD_INSTRUCCION = 32

)
(
  input i_clock,
  input i_reset,
  input i_tx_done,
  input i_rx_done,
  input [OUTPUT_WORD_LENGTH - 1 : 0] i_data_rx,
  output reg o_tx_start,
  output reg [OUTPUT_WORD_LENGTH - 1 : 0] o_data_tx,
  output reg o_soft_reset,
  output reg o_write_mem_programa,
  output reg [ADDR_MEM_LENGTH - 1 : 0] o_addr_mem_programa,
  output reg [DATO_MEM_LENGTH - 1 : 0] o_dato_mem_programa,
  output reg modo_ejecucion
 );

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
localparam ESPERA         = 4'b0001;
localparam SOFT_RESET     = 4'b0010;    // L: parte menos significativa.
localparam READ_PROGRAMA  = 4'b0100;    // H: parte mas significativa.
localparam ESPERA_START   = 4'b1000;

localparam CANT_BITS_CONTADOR_DATOS = clogb2 (LONGITUD_INSTRUCCION / OUTPUT_WORD_LENGTH);
localparam CANT_BITS_DEPTH_MEM = 2 ** ADDR_MEM_LENGTH;

// Registros.
reg [ CANTIDAD_ESTADOS - 1 : 0 ] reg_state;
reg [ CANTIDAD_ESTADOS - 1 : 0 ] reg_next_state;
reg registro_rx_done;
reg [LONGITUD_INSTRUCCION - 1 : 0] reg_instruccion;
reg [CANT_BITS_CONTADOR_DATOS - 1 : 0] reg_contador_datos;
reg [CANT_BITS_DEPTH_MEM - 1 : 0] reg_contador_addr_mem;
reg [DATO_MEM_LENGTH - 1 : 0] o_next_dato_mem_programa;
//reg [OUTPUT_WORD_LENGTH - 1 : 0] o_data_tx_next;
//reg registro_tx_done;




always @ ( posedge i_clock ) begin //Memory
  // Se resetean los registros.
 if (~ i_reset) begin
     reg_state <= 1;
     registro_rx_done <= 0;
     reg_instruccion <= 1;
     reg_contador_datos <= 0;
     reg_contador_addr_mem <= 0;
     o_dato_mem_programa <= 0;
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
         if (reg_contador_datos ==  { CANT_BITS_CONTADOR_DATOS {1'b1} }) begin
           reg_contador_addr_mem <= reg_contador_addr_mem + 1;
         end
         else begin
           reg_contador_addr_mem <= reg_contador_addr_mem;
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
           if ((~i_rx_done & registro_rx_done) && (i_data_rx == 8'b00000001)) begin
               reg_next_state = READ_PROGRAMA;
           end
           else begin
               reg_next_state = SOFT_RESET;
           end
       end

       READ_PROGRAMA : begin
           if ((reg_instruccion == 0) && (reg_contador_datos == { CANT_BITS_CONTADOR_DATOS {1'b1} } ) ) begin
               reg_next_state = ESPERA_START;
           end
           else begin
               reg_next_state = READ_PROGRAMA;
           end
       end
       ESPERA_START : begin
           if ((~i_rx_done & registro_rx_done) && ((i_data_rx == 8'b0000011) || (i_data_rx == 8'b0000111))) begin
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
         modo_ejecucion = 0; // Continuo.
       end

       SOFT_RESET : begin
         o_tx_start = 0;
         o_data_tx = 0;
         o_soft_reset = 0; //Logica por nivel bajo.
         o_write_mem_programa = 0; //Write es en 1.
         o_addr_mem_programa = 0;
         o_next_dato_mem_programa = 0;
         modo_ejecucion = 0; // Continuo.
       end

       READ_PROGRAMA : begin
         o_tx_start = 0;
         o_data_tx = 0;
         o_soft_reset = 1; //Logica por nivel bajo.
         o_write_mem_programa = 1; //Write es en 1.
         o_addr_mem_programa = reg_contador_addr_mem;
         if (reg_contador_datos ==  { CANT_BITS_CONTADOR_DATOS {1'b1} }) begin
           o_next_dato_mem_programa = reg_instruccion;
         end
         else begin
           o_next_dato_mem_programa = o_dato_mem_programa;
         end
         modo_ejecucion = 0; // Continuo.
       end

       ESPERA_START : begin
         o_tx_start = 0;
         o_data_tx = 0;
         o_soft_reset = 1; //Logica por nivel bajo.
         o_write_mem_programa = 0; //Write es en 1.
         o_addr_mem_programa = 0;
         o_next_dato_mem_programa = 0;
         modo_ejecucion = i_data_rx [2];// Continuo en cero, paso a paso en 1.
       end

       default : begin
         o_tx_start = 0;
         o_data_tx = 0;
         o_soft_reset = 1; //Logica por nivel bajo.
         o_write_mem_programa = 0; //Write es en 1.
         o_addr_mem_programa = 0;
         o_next_dato_mem_programa = 0;
         modo_ejecucion = 0; // Continuo.
       end

 endcase
end

endmodule
