`timescale 1ns / 1ps

module instruction_decoder
#(
  parameter OPCODE_LENGTH = 5
)

(
  input [OPCODE_LENGTH - 1 : 0] i_opcode,
  output reg o_wrPC,
  output reg o_wrACC,
  output reg [1 : 0] o_selA,
  output reg o_selB,
  output reg [OPCODE_LENGTH - 1 : 0] o_opcode,
  output reg o_wrRAM,
  output reg o_rdRAM
);


  always @(*) begin
    case (i_opcode)

      5'b00000 : begin //HALT
        o_wrPC = 0;
        o_wrACC = 0;
        o_selA = 0;
        o_selB = 0;
        o_opcode = i_opcode;
        o_wrRAM = 0;
        o_rdRAM = 0;
      end

      5'b00001 : begin //STORE VARIABLE
        o_wrPC = 1;
        o_wrACC = 0;
        o_selA = 0;
        o_selB = 0;
        o_opcode = i_opcode;
        o_wrRAM = 1;
        o_rdRAM = 0;
      end

      5'b00010 : begin //LOAD VARIABLE
        o_wrPC = 1;
        o_wrACC = 1;
        o_selA = 0;
        o_selB = 0;
        o_opcode = i_opcode;
        o_wrRAM = 0;
        o_rdRAM = 1;
      end

      5'b00011 : begin //LOAD INMEDIATE
        o_wrPC = 1;
        o_wrACC = 1;
        o_selA = 1;
        o_selB = 0;
        o_opcode = i_opcode;
        o_wrRAM = 0;
        o_rdRAM = 0;
      end

      5'b00100 : begin //ADD VARIABLE
        o_wrPC = 1;
        o_wrACC = 1;
        o_selA = 2;
        o_selB = 0;
        o_opcode = i_opcode;
        o_wrRAM = 0;
        o_rdRAM = 1;
      end

      5'b00101 : begin //ADD INMEDIATE
        o_wrPC = 1;
        o_wrACC = 1;
        o_selA = 2;
        o_selB = 1;
        o_opcode = i_opcode;
        o_wrRAM = 0;
        o_rdRAM = 0;
      end

      5'b00110 : begin //SUB VARIABLE
        o_wrPC = 1;
        o_wrACC = 1;
        o_selA = 2;
        o_selB = 0;
        o_opcode = i_opcode;
        o_wrRAM = 0;
        o_rdRAM = 1;
      end

      5'b00111 : begin //SUB INMEDIATE
        o_wrPC = 1;
        o_wrACC = 1;
        o_selA = 2;
        o_selB = 1;
        o_opcode = i_opcode;
        o_wrRAM = 0;
        o_rdRAM = 0;
      end

      default begin
        o_wrPC = 0;
        o_wrACC = 0;
        o_selA = 0;
        o_selB = 0;
        o_opcode = i_opcode;
        o_wrRAM = 0;
        o_rdRAM = 0;
      end

    endcase
  end

endmodule
