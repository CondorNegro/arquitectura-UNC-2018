 `timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 2. UART.
// Modulo rx.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////////////////////

module rx(
  i_clock,
  i_rate,
  i_bit_rx,
  i_reset,
  o_rx_done,
  o_data_out
  );

// Parametros.
parameter WIDTH_WORD        = 8;
parameter CANT_BIT_STOP     = 2;

// Local Param
localparam ESPERA = 5'b00001;
localparam START = 5'b00010;
localparam READ = 5'b00100;
localparam STOP = 5'b01000;
localparam ERROR = 5'b10000; // Estado en caso de error en bits de stop (llega un 1 como primer bit de stop y luego un 0).


// Entradas - Salidas.
input i_clock;
input i_rate;
input i_bit_rx;
input i_reset;
output reg o_rx_done;
output reg [ WIDTH_WORD - 1 : 0 ] o_data_out;



// Registros.
reg [ 4 : 0 ] reg_state;
reg [ 4 : 0 ] reg_next_state;
reg [ WIDTH_WORD - 1 : 0 ] reg_next_buffer;
reg [ 5 : 0] reg_contador_ticks, reg_next_contador_ticks; // Debe contar como maximo hasta 32. (Por los dos bits de stop).
reg [$clog2 (WIDTH_WORD) : 0] reg_contador_bits, reg_next_contador_bits;
reg [($clog2 (CANT_BIT_STOP)) : 0] reg_contador_bits_stop, reg_next_contador_bits_stop;




always@( posedge i_clock ) begin //Memory

  // Se resetean los registros.
  if (~ i_reset) begin
          reg_state <= 1;
          o_data_out <= 0;
          reg_contador_bits <= 0;
          reg_contador_ticks <= 0;
          reg_contador_bits_stop <= 0;
  end

  else begin
      reg_state <= reg_next_state;
      o_data_out <= reg_next_buffer;
      reg_contador_bits <= reg_next_contador_bits;
      reg_contador_ticks <= reg_next_contador_ticks;
      reg_contador_bits_stop <= reg_next_contador_bits_stop;
  end

end


always@( * ) begin //NEXT - STATE logic

   reg_next_state = reg_state;
   o_rx_done = 1'b0;
   reg_next_contador_ticks = reg_contador_ticks;
   reg_next_contador_bits = reg_contador_bits;
   reg_next_contador_bits_stop = reg_contador_bits;
   reg_next_buffer = o_data_out;

  case (reg_state)

      ESPERA : begin
          if (i_bit_rx == 0) begin
              reg_next_state = START;
              reg_next_contador_ticks = 0;
          end
          else begin
              reg_next_state = ESPERA;
          end
      end

      START : begin
           if (i_rate) begin
              if (reg_contador_ticks == 8) begin
                  reg_next_state = READ;
                  reg_next_contador_bits = 0;
                  reg_next_contador_ticks = 0;
              end
              else begin
                  reg_next_state = START;
                  reg_next_contador_ticks = reg_contador_ticks + 1;
              end
           end

      end

      READ : begin
           if (i_rate) begin
                if (reg_contador_bits == WIDTH_WORD) begin
                    reg_next_state = STOP;
                    reg_next_contador_ticks = 0;
                    reg_next_contador_bits_stop = 0;
                    reg_next_contador_bits = 0;
                end
                else begin
                   reg_next_state = READ;
                   if (reg_contador_ticks == 15) begin
                         reg_next_contador_bits = reg_next_contador_bits + 1;
                         reg_next_contador_ticks = 0;
                         reg_next_buffer[(WIDTH_WORD-1) - reg_contador_bits] =  i_bit_rx;
                   end
                   else begin
                       reg_next_contador_ticks = reg_next_contador_ticks + 1;
                   end
                end
           end
      end

      STOP : begin
           if (i_rate) begin
               if (reg_contador_bits_stop == CANT_BIT_STOP) begin
                 reg_next_state = ESPERA;
                 reg_next_contador_bits = 0;
                 reg_next_contador_ticks = 0;
                 o_rx_done = 1;
               end
               else begin
                 if (reg_contador_ticks == 15) begin
                       reg_next_contador_bits_stop = reg_next_contador_bits_stop + 1;
                       reg_next_contador_ticks = 0;
                 end
                 else begin
                   reg_next_contador_ticks = reg_next_contador_ticks + 1;
                 end
               end 
           end
     end
     default: begin
           reg_next_state = START;
           reg_next_contador_ticks = 0;
           reg_next_contador_bits_stop = 0;
           reg_next_contador_bits = 0;
     end

  endcase
end

endmodule
