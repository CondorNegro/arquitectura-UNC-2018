`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 3. BIP I.
// Datapath.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////

module datapath
#(
  parameter OPERANDO_LENGTH = 11,         // Cantidad de bits del operando.
  parameter OPERANDO_FINAL_LENGHT = 16,   // Cantidad de bits del operando con extension de signo.
  parameter OPCODE_LENGTH = 5             // Cantidad de bits del opcode.

)

(
  input i_clock,
  input i_reset,
  input [2-1:0] i_selA,
  input i_selB,
  input i_wrACC,
  input [OPCODE_LENGTH - 1 : 0] i_opcode,
  input [OPERANDO_LENGTH - 1 : 0] i_operando,
  input [OPERANDO_FINAL_LENGHT - 1 : 0] i_outmemdata,
  output [OPERANDO_LENGTH - 1 : 0] o_addr,
  output [OPERANDO_FINAL_LENGHT - 1 : 0] o_ACC
);


  // Registros.

  reg [OPERANDO_FINAL_LENGHT - 1 : 0] reg_ACC;
  reg signed [OPERANDO_FINAL_LENGHT - 1 : 0] reg_signo_extendido;
  reg signed [OPERANDO_FINAL_LENGHT - 1 : 0] reg_out_muxA;
  reg signed [OPERANDO_FINAL_LENGHT - 1 : 0] reg_out_muxB;
  reg signed [OPERANDO_FINAL_LENGHT - 1 : 0] reg_out_ALU;



  always @(posedge i_clock) begin
    if (~i_reset) begin // Se resetean los registros.
      reg_ACC <= 0;
    end
    else begin
      if (i_wrACC) begin // Deteccion de flanco ascendente.
            reg_ACC <= reg_out_muxA;  // Escribo ACC.
      end
      else begin
            reg_ACC <= reg_ACC;
      end
    end
  end

  always @(*) begin // Extension de signo.
      reg_signo_extendido = {{5 {i_operando [OPERANDO_LENGTH - 1]}},i_operando}; //replico el signo
  end

  always @(*) begin // mux A
    case (i_selA)
      2'b00 : begin
        reg_out_muxA = i_outmemdata;
      end
      2'b01 : begin
        reg_out_muxA = reg_signo_extendido;
      end
      2'b10 : begin
        reg_out_muxA = reg_out_ALU;
      end
      default begin
          reg_out_muxA = 0;
        end
    endcase
  end

  always @(*) begin // mux B
    case (i_selB)
      1'b0 : begin
        reg_out_muxB = i_outmemdata;
      end
      1'b1 : begin
        reg_out_muxB = reg_signo_extendido;
      end
    endcase
  end


  always@(i_opcode or reg_ACC or reg_out_muxB) begin  // Unidad aritmética.

      // Case donde se testea el valor del codigo de operacion y en base
      // a eso se opera entre operando1 y operando2.
      case (i_opcode)

          //ADD
          5'b00100 : begin
              reg_out_ALU = reg_ACC + reg_out_muxB;
          end
          5'b00101 : begin
              reg_out_ALU = reg_ACC + reg_out_muxB;
          end

            //SUB
            5'b00110 : begin
              reg_out_ALU = reg_ACC - reg_out_muxB;
            end
            5'b00111 : begin
              reg_out_ALU = reg_ACC - reg_out_muxB;
            end


          default : begin
              reg_out_ALU = reg_ACC;
          end

      endcase

  end

  assign o_ACC = reg_ACC;
  assign o_addr = i_operando;

endmodule
