`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// TOP del instruction fetch.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////////////////////


module top_if
   #(
       parameter RAM_WIDTH_PROGRAMA = 32,
       parameter RAM_PERFORMANCE_PROGRAMA= "LOW_LATENCY",
       parameter INIT_FILE_PROGRAMA = "",
       parameter RAM_DEPTH_PROGRAMA = 2048,
       parameter CANT_BITS_ADDR = 11

   )
   (
       input i_clock,
       input i_soft_reset,

       input i_enable_contador_PC,

       input i_enable_mem,
       input i_write_read_mem,
       input i_rsta_mem,
       input i_regcea_mem,
       input [CANT_BITS_ADDR - 1 : 0] i_addr_mem_programa,
       input [RAM_WIDTH_PROGRAMA - 1 : 0] i_data_mem_programa,

       input i_control_mux_PC,
       input i_control_mux_addr_mem,
       

       input [CANT_BITS_ADDR - 1 : 0] i_branch_dir,

       input i_enable_pipeline,

       input i_bit_burbuja_hazard,

       output [RAM_WIDTH_PROGRAMA - 1 : 0] o_instruction,
       output [CANT_BITS_ADDR - 1 : 0] o_direccion_adder_pc,
       output [CANT_BITS_ADDR - 1 : 0] o_contador_programa,
       output o_led_mem,
       output o_reset_ack_mem
   );


wire [ CANT_BITS_ADDR - 1 : 0 ] wire_output_mux2_TO_addr_memoria_programa;
wire [CANT_BITS_ADDR - 1 : 0] wire_output_mux1_TO_idata_pc;
wire [RAM_WIDTH_PROGRAMA - 1 : 0] wire_output_data_mem_programa_TO_dataA_mux3;

wire [RAM_WIDTH_PROGRAMA - 1 : 0] wire_output_mux3_TO_IR;
reg [RAM_WIDTH_PROGRAMA - 1 : 0] reg_intruction_register;
assign o_instruction = reg_intruction_register;


wire [CANT_BITS_ADDR - 1 : 0] wire_direccion_adder_pc;
reg [RAM_WIDTH_PROGRAMA - 1 : 0] reg_direccion_adder_pc;
assign o_direccion_adder_pc = reg_direccion_adder_pc;


always@(negedge i_clock) begin
  if (~i_soft_reset) begin
    reg_intruction_register <= 32'b00000000001000010000100000100100; // NOP (AND R1,R1,R1)
    reg_direccion_adder_pc <= 1;
  end
  else begin
    if (i_enable_pipeline & ~i_bit_burbuja_hazard) begin
        reg_intruction_register <= wire_output_mux3_TO_IR;
        reg_direccion_adder_pc <= wire_direccion_adder_pc;
    end
    else begin
        reg_intruction_register <= reg_intruction_register;
        reg_direccion_adder_pc <= reg_direccion_adder_pc;
    end
  end
end

memoria_programa
   #(
       .RAM_WIDTH (RAM_WIDTH_PROGRAMA),
       .RAM_PERFORMANCE (RAM_PERFORMANCE_PROGRAMA),
       .INIT_FILE (INIT_FILE_PROGRAMA),
       .RAM_DEPTH (RAM_DEPTH_PROGRAMA)
   )
   u_memoria_programa_1
   (
       .i_clk (i_clock),
       .i_addr (wire_output_mux2_TO_addr_memoria_programa),
       .i_data (i_data_mem_programa),
       .i_wea (i_write_read_mem),
       .i_ena (i_enable_mem),
       .i_rsta (i_rsta_mem),
       .i_regcea (i_regcea_mem),
       .i_soft_reset (i_soft_reset),
       .o_data (wire_output_data_mem_programa_TO_dataA_mux3),
       .o_reset_ack (o_reset_ack_mem),
       .o_led (o_led_mem)
   );

mux
   #(
       .INPUT_OUTPUT_LENGTH (CANT_BITS_ADDR)
   )
   u_mux_PC_1
   (
       .i_data_A (o_direccion_adder_pc),
       .i_data_B (i_branch_dir),
       .i_selector (i_control_mux_PC),
       .o_result (wire_output_mux1_TO_idata_pc)
 );

mux
   #(
       .INPUT_OUTPUT_LENGTH (CANT_BITS_ADDR)
   )
   u_mux_addr_mem_2
   (
       .i_data_A (o_contador_programa),
       .i_data_B (i_addr_mem_programa),
       .i_selector (i_control_mux_addr_mem),
       .o_result (wire_output_mux2_TO_addr_memoria_programa)
   );

   mux
      #(
          .INPUT_OUTPUT_LENGTH (RAM_WIDTH_PROGRAMA)
      )
      u_mux_output_3
      (
          .i_data_A (wire_output_data_mem_programa_TO_dataA_mux3),
          .i_data_B (32'b00000000001000010000100000100100), /* AND R1, R1, R1  (actua como NOP)*/
          .i_selector (i_control_mux_PC),
          .o_result ( wire_output_mux3_TO_IR)
      );

adder
   #(
       .INPUT_OUTPUT_LENGTH (CANT_BITS_ADDR)
   )
   u_adder_1
   (
       .i_data_A (o_contador_programa),
       .i_data_B (10'b0000000001),
       .o_result (wire_direccion_adder_pc)
   );


   pc
      #(
          .CONTADOR_LENGTH (CANT_BITS_ADDR)
      )
      u_pc_1
      (
          .i_clock (i_clock),
          .i_soft_reset (i_soft_reset),
          .i_enable (i_enable_contador_PC & ~i_bit_burbuja_hazard),
          .i_direccion (wire_output_mux1_TO_idata_pc),
          .o_direccion (o_contador_programa)
      );

endmodule
