 `timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 3. BIP I.
// Interface_circuit.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////////////////////


module interface_circuit
 #(
   parameter CANT_BITS_OPCODE = 5,      //  Cantidad de bits del opcode.
   parameter CC_LENGTH = 11,            //  Cantidad de bits del contador de ciclos.
   parameter ACC_LENGTH = 16,           //  Cantidad de bits del acumulador.
   parameter OUTPUT_WORD_LENGTH = 8,    //  Cantidad de bits de la palabra a transmitir.
   parameter HALT_OPCODE = 0            //  Opcode de la instruccion HALT.
 )
 (
   input i_clock,
   input i_reset,
   input i_tx_done,
   input [CC_LENGTH - 1 : 0] i_CC,                      // Contador de ciclos.
   input [ACC_LENGTH - 1 : 0] i_ACC,                    // Acumulador.
   input [CANT_BITS_OPCODE - 1 : 0] i_opcode,
   input i_rx_done, 
   input [OUTPUT_WORD_LENGTH - 1 : 0] i_data_rx,
   output reg o_tx_start,
   output reg [OUTPUT_WORD_LENGTH - 1 : 0] o_data_tx,
   output reg o_soft_reset
  //o_prueba
  );



// Local Param
localparam ESPERA = 5'b00001;
localparam CC_L_PART = 5'b00010;    // L: parte menos significativa.      
localparam CC_H_PART = 5'b00100;    // H: parte mas significativa.
localparam ACC_L_PART = 5'b01000;
localparam ACC_H_PART = 5'b10000;



//output reg o_prueba;

// Registros.
reg [ 4 : 0 ] reg_state;
reg [ 4 : 0 ] reg_next_state;
reg registro_tx_done;
reg [OUTPUT_WORD_LENGTH - 1 : 0] o_data_tx_next;
reg [OUTPUT_WORD_LENGTH - 1 : 0] reg_data_rx;
reg [OUTPUT_WORD_LENGTH - 1 : 0] reg_next_data_rx;
reg reg_contador_datos;   
reg reg_next_contador_datos;
reg registro_rx_done;

// En total envio desde la PC 2 señales. 
// Primero envio un 8'b00000001 para resetear el BIP I.
// Segundo envio un 8'b00000010 para iniciar el funcionamiento del BIP I.




always@( posedge i_clock ) begin //Memory
   // Se resetean los registros.
  if (~ i_reset) begin
      reg_state <= 1;
      registro_tx_done <= 0;
      registro_rx_done <= 0;
      o_data_tx <= 0;
      reg_data_rx <= 0;
      reg_contador_datos <= 0;
      o_soft_reset <= 1; 
  end

  else begin
      registro_tx_done <= i_tx_done;
      registro_rx_done <= i_rx_done;
      reg_state <= reg_next_state;
      o_data_tx <= o_data_tx_next;
      reg_data_rx <= reg_next_data_rx;
      reg_contador_datos <= reg_next_contador_datos;
      if (reg_contador_datos == 1'b1) begin
        o_soft_reset <= 0; // Reset BIP.
      end
      else begin 
        o_soft_reset <= 1; //Levanto el reset por software. Comienza a funcionar el sistema.
      end
  end
end


always@(*) begin //Rx y handler soft reset.
    if (i_rx_done & ~registro_rx_done) begin  //Deteccion de flanco ascendente.
        reg_next_data_rx = i_data_rx;
        if (((reg_contador_datos == 0) && 
            (reg_next_data_rx == 1)) ||
            ((reg_contador_datos == 1) && 
            (reg_next_data_rx == 2))) begin  //Señales validas.
            
            reg_next_contador_datos = reg_contador_datos + 1; // Contador con overflow.
        
        end
        else begin
            reg_next_contador_datos = reg_contador_datos;
        end
    end    
    else begin
        reg_next_data_rx = reg_data_rx;
        reg_next_contador_datos = reg_contador_datos;
    end
end

always@( * ) begin //NEXT - STATE logic

  case (reg_state)

      ESPERA : begin
          if (i_opcode == HALT_OPCODE) begin
              reg_next_state = CC_L_PART;
          end
          else begin
              reg_next_state = ESPERA;
          end
      end

      CC_L_PART : begin
         if ( (i_tx_done == 1) && (registro_tx_done == 0))  begin // Deteccion de flanco ascendente
              reg_next_state = CC_H_PART;
          end
          else begin
              reg_next_state = CC_L_PART;
          end
      end

      CC_H_PART : begin
          if ( (i_tx_done == 1) && (registro_tx_done == 0))  begin  // Deteccion de flanco ascendente
              reg_next_state = ACC_L_PART;
          end
          else begin
              reg_next_state = CC_H_PART;
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

      CC_L_PART : begin
          o_tx_start = 1;
          o_data_tx_next = i_CC [OUTPUT_WORD_LENGTH - 1 : 0];   // Transmito parte menos significativa.
      end

      CC_H_PART : begin
          o_tx_start = 1;       // Transmito parte mas significativa del contador de ciclos.
          o_data_tx_next = {{(OUTPUT_WORD_LENGTH - (CC_LENGTH - OUTPUT_WORD_LENGTH)) {1'b0}}, i_CC [CC_LENGTH - 1 : OUTPUT_WORD_LENGTH]};
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
