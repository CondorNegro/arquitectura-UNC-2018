`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// TOP de la etapa de ejecucion.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////////////////////


module top_ejecucion
   #(
       
       parameter WIDTH_DATA_MEM = 32,
       parameter CANT_REGISTROS= 32,
       parameter CANT_BITS_ADDR = 11,
       parameter CANT_BITS_REGISTROS = 32,
       parameter CANT_BITS_ALU_CONTROL = 4,
       parameter CANT_BITS_SELECT_BYTES_MEM_DATA = 2  
   )
   (
       input i_clock,
       input i_soft_reset,
       
    

       input i_enable_pipeline,
       
       input [CANT_BITS_ADDR - 1 : 0] i_adder_pc,
       input [CANT_BITS_REGISTROS - 1 : 0] i_data_A,
       input [CANT_BITS_REGISTROS - 1 : 0] i_data_B,

       input [CANT_BITS_REGISTROS - 1 : 0] i_extension_signo_constante,
       input [clogb2 (CANT_REGISTROS - 1) - 1 : 0] i_reg_rs,
       input [clogb2 (CANT_REGISTROS - 1) - 1 : 0] i_reg_rt,
       input [clogb2 (CANT_REGISTROS - 1) - 1 : 0] i_reg_rd,
       input i_halt_detected,
       
       // Control

       input i_RegDst,
       input i_RegWrite,
       input i_ALUSrc,
       input i_MemRead,
       input i_MemWrite,
       input i_MemtoReg,
       input [CANT_BITS_ALU_CONTROL - 1 : 0] i_ALUCtrl,
       input [CANT_BITS_SELECT_BYTES_MEM_DATA - 1 : 0] i_select_bytes_mem_datos,
      


       output reg o_RegWrite,
       output reg o_MemRead,
       output reg o_MemWrite,
       output reg o_MemtoReg,
       output reg [CANT_BITS_SELECT_BYTES_MEM_DATA - 1 : 0] o_select_bytes_mem_datos,


       output reg o_halt_detected,
       output reg [WIDTH_DATA_MEM - 1 : 0] o_result,
       output reg [WIDTH_DATA_MEM - 1 : 0] o_data_write_to_mem,
       output reg [clogb2 (CANT_REGISTROS - 1) - 1 : 0] o_registro_destino,

       output o_led
   );



    //  The following function calculates the address width based on specified RAM depth
    function integer clogb2;
        input integer depth;
            for (clogb2=0; depth>0; clogb2=clogb2+1)
                depth = depth >> 1;
    endfunction


    wire [WIDTH_DATA_MEM - 1 : 0] wire_result_alu;
    wire [WIDTH_DATA_MEM - 1 : 0] wire_data_write_to_mem;
    wire [clogb2 (CANT_REGISTROS - 1) - 1 : 0] wire_registro_destino;
    wire [CANT_BITS_REGISTROS - 1 : 0] wire_segundo_operando_alu;
    wire [CANT_BITS_REGISTROS - 1 : 0] wire_primer_operando_alu;

    wire wire_control_mux_primer_operando_alu;

    assign wire_control_mux_primer_operando_alu = (i_ALUCtrl == 14); // Es un salto o no.

    assign wire_data_write_to_mem = i_data_B;


    always@(negedge i_clock) begin
      if (~i_soft_reset) begin
            o_RegWrite <= 1'b0;
            o_MemRead  <= 1'b0;
            o_MemWrite <= 1'b0;
            o_MemtoReg <= 1'b0;
            o_result   <= 0;
            o_data_write_to_mem <= 0;
            o_registro_destino <= 0;
            o_halt_detected <= 1'b0;
            o_select_bytes_mem_datos <= 0;
      end
      else begin
            if (i_enable_pipeline) begin
                o_RegWrite <= i_RegWrite;
                o_MemRead  <= i_MemRead;
                o_MemWrite <= i_MemWrite;
                o_MemtoReg <= i_MemtoReg;
                o_result   <= wire_result_alu;
                o_data_write_to_mem <= wire_data_write_to_mem;
                o_registro_destino <= wire_registro_destino;
                o_halt_detected <= i_halt_detected;
                o_select_bytes_mem_datos <= i_select_bytes_mem_datos;
            end
            else begin
                o_RegWrite <= o_RegWrite;
                o_MemRead  <= o_MemRead;
                o_MemWrite <= o_MemWrite;
                o_MemtoReg <= o_MemtoReg;
                o_result   <= o_result;
                o_data_write_to_mem <= o_data_write_to_mem;
                o_registro_destino <= o_registro_destino;
                o_halt_detected <= o_halt_detected;
                o_select_bytes_mem_datos <= o_select_bytes_mem_datos;
            end 
    end
    end

   



mux
   #(
       .INPUT_OUTPUT_LENGTH (clogb2 (CANT_REGISTROS - 1))
    )
    u_mux_reg_dst_1
   (
       .i_data_A (i_reg_rt),
       .i_data_B (i_reg_rd),
       .i_selector (i_RegDst),
       .o_result (wire_registro_destino)
    );


mux
   #(
       .INPUT_OUTPUT_LENGTH (CANT_BITS_REGISTROS)
    )
    u_mux_second_operand_alu_1
   (
       .i_data_A (i_data_B),
       .i_data_B (i_extension_signo_constante),
       .i_selector (i_ALUSrc),
       .o_result (wire_segundo_operando_alu)
    );

mux
   #(
       .INPUT_OUTPUT_LENGTH (CANT_BITS_REGISTROS)
    )
    u_mux_first_operand_alu_1
   (
       .i_data_A (i_data_A),
       .i_data_B ({ { (CANT_BITS_REGISTROS - CANT_BITS_ADDR) {1'b0}}, i_adder_pc}),
       .i_selector (wire_control_mux_primer_operando_alu),
       .o_result (wire_primer_operando_alu)
    );


alu 
    #(
        .CANT_BITS_ALU_CONTROL (CANT_BITS_ALU_CONTROL),
        .CANT_BITS_DATO (CANT_BITS_REGISTROS)
    )
    u_alu_1
    (
        .i_ALUCtrl (i_ALUCtrl),
        .i_datoA (wire_primer_operando_alu),
        .i_datoB (wire_segundo_operando_alu),
        .o_resultado (wire_result_alu)
    );



  

endmodule
