 `timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 2. UART.
// Interface_circuit.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////////////////////



`define WIDTH_WORD_INTERFACE        8       // Tamanio de palabra de la trama UART.



module interface_circuit
 #(
   parameter CANT_BITS_OPCODE = 5,
   parameter PC_LENGTH = 11,
   parameter ACC_LENGTH = 16,
   parameter OUTPUT_WORD_LENGTH = 8,
   parameter HALT_OPCODE = 0
 )
 (
   input i_clock,
   input i_reset,
   input i_tx_done,
   input [PC_LENGTH - 1 : 0] i_PC,
   input [ACC_LENGTH - 1 : 0] i_ACC,
   input [CANT_BITS_OPCODE - 1 : 0] i_opcode,
   output reg o_tx_start,
   output reg [OUTPUT_WORD_LENGTH - 1 : 0] o_data_tx
  //o_prueba
  );



// Local Param
localparam ESPERA = 5'b00001;
localparam PC_L_PART = 5'b00010;
localparam PC_H_PART = 5'b00100;
localparam ACC_L_PART = 5'b01000;
localparam ACC_H_PART = 5'b10000;



//output reg o_prueba;

// Registros.
reg [ 4 : 0 ] reg_state;
reg [ 4 : 0 ] reg_next_state;

reg registro_tx_done;

reg [OUTPUT_WORD_LENGTH - 1 : 0] o_data_tx_next;




always@( posedge i_clock ) begin //Memory
   // Se resetean los registros.
  if (~ i_reset) begin
      reg_state <= 1;
      registro_tx_done <= 0;
      o_data_tx <= 0;

  end

  else begin
      registro_tx_done <= i_tx_done;
      reg_state <= reg_next_state;
      o_data_tx <= o_data_tx_next;
  end
end




always@( * ) begin //NEXT - STATE logic

  case (reg_state)

      ESPERA : begin
          if (i_opcode == HALT_OPCODE) begin
              reg_next_state = PC_L_PART;
          end
          else begin
              reg_next_state = ESPERA;
          end
      end

      PC_L_PART : begin
         if ( (i_tx_done == 1) && (registro_tx_done == 0))  begin
              reg_next_state = PC_H_PART;
          end
          else begin
              reg_next_state = PC_L_PART;
          end
      end

      PC_H_PART : begin
          if ( (i_tx_done == 1) && (registro_tx_done == 0))  begin  // Deteccion de flanco ascendente
              reg_next_state = ACC_L_PART;
          end
          else begin
              reg_next_state = PC_H_PART;
          end
      end

      ACC_L_PART : begin
          if ( (i_tx_done == 1) && (registro_tx_done == 0)) begin
              reg_next_state = ACC_H_PART;
          end
          else begin
              reg_next_state = ACC_L_PART;
          end
      end

      ACC_H_PART : begin
          if ( (i_tx_done == 1) && (registro_tx_done == 0)) begin
              reg_next_state = ESPERA;
          end
          else begin
              reg_next_state = ACC_H_PART;
          end
      end

      default begin
          reg_next_state = ESPERA;
      end
  endcase
end


always@( * ) begin //Output logic
  //o_prueba = 0;
  case (reg_state)

      ESPERA : begin
          o_tx_start = 0;
          o_data_tx_next = o_data_tx;
      end

      PC_L_PART : begin
          o_tx_start = 1;
          o_data_tx_next = i_PC [OUTPUT_WORD_LENGTH - 1 : 0];
      end

      PC_H_PART : begin
          o_tx_start = 1;
          o_data_tx_next = {{(OUTPUT_WORD_LENGTH - (PC_LENGTH - OUTPUT_WORD_LENGTH)) {1'b0}}, i_PC [PC_LENGTH - 1 : OUTPUT_WORD_LENGTH]};
      end

      ACC_L_PART : begin
          o_tx_start = 1;
          o_data_tx_next = i_ACC [OUTPUT_WORD_LENGTH - 1 : 0];
      end

      ACC_H_PART : begin
          o_tx_start = 1;
          o_data_tx_next = {{(OUTPUT_WORD_LENGTH - (ACC_LENGTH - OUTPUT_WORD_LENGTH)) {1'b0}}, i_ACC [ACC_LENGTH - 1 : OUTPUT_WORD_LENGTH]};
      end

      default : begin
          o_tx_start = 0;
          o_data_tx_next = o_data_tx;
      end

  endcase
end

endmodule
