`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// TOP de la etapa de memoria de datos.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////////////////////


module top_mem
   #(
       
       parameter RAM_WIDTH = 32,
       parameter RAM_PERFORMANCE = "LOW_LATENCY",
       parameter INIT_FILE = "",
       parameter RAM_DEPTH = 1024,
       parameter CANT_COLUMNAS_MEM_DATOS = 4,
       parameter CANT_REGISTROS= 32,
       parameter CANT_BITS_ADDR = 12, // Los dos bits LSB direccionan a nivel de byte.
       parameter CANT_BITS_REGISTROS = 32,
       parameter CANT_BITS_SELECT_BYTES_MEM_DATA = 3
 
   )
   (
       input i_clock,
       input i_soft_reset,
       
       input i_enable_pipeline,
       
       input i_halt_detected,

       input i_control_address_mem,
       input i_enable_mem_datos,

       input [CANT_BITS_REGISTROS - 1 : 0] i_address_ALU,
       input [CANT_BITS_ADDR - 1 : 0] i_address_debug_unit,
       input [CANT_BITS_REGISTROS - 1 : 0] i_data_write_mem,
       
       
       // Control

       
       input i_RegWrite,
       input i_MemRead,
       input i_MemWrite,
       input i_MemtoReg,
       input [CANT_BITS_SELECT_BYTES_MEM_DATA - 1 : 0] i_select_bytes_mem_datos,
       input [clogb2 (CANT_REGISTROS - 1) - 1 : 0] i_registro_destino,

       
       
       output reg o_RegWrite,
       output reg o_MemtoReg,
       output reg [clogb2 (CANT_REGISTROS - 1) - 1 : 0] o_registro_destino,
       output reg o_halt_detected,
       output reg [CANT_BITS_REGISTROS - 1 : 0] o_data_alu,
       output reg [CANT_BITS_REGISTROS - 1 : 0] o_data_mem,
       
       output o_soft_reset_ack,
       
       output [CANT_BITS_REGISTROS - 1 : 0] o_dato_mem_to_debug_unit,
       output o_bit_sucio_to_debug_unit,

       output o_led
   );



    //  The following function calculates the address width based on specified RAM depth
    function integer clogb2;
        input integer depth;
            for (clogb2=0; depth>0; clogb2=clogb2+1)
                depth = depth >> 1;
    endfunction


    wire [CANT_BITS_ADDR - 1 : 0] wire_address_mem;
    wire [CANT_BITS_REGISTROS - 1 : 0] wire_dato_mem_acondicionado;
    wire [CANT_BITS_REGISTROS - 1 : 0] wire_dato_mem_output;
    wire [CANT_COLUMNAS_MEM_DATOS - 1 : 0] wire_wea_mem;
    wire wire_soft_reset_ack_mem_datos;
    wire wire_bit_sucio;

    assign o_bit_sucio_to_debug_unit = wire_bit_sucio;
    assign o_soft_reset_ack = wire_soft_reset_ack_mem_datos;


    always@(negedge i_clock) begin
      if (~i_soft_reset) begin
            o_RegWrite <= 1'b0;
            o_MemtoReg <= 1'b0;
            o_registro_destino <= 0;
            o_halt_detected <= 1'b0;
            o_data_alu <= 0;
            o_data_mem <= 0;
      end
      else begin
            if (i_enable_pipeline) begin
                o_RegWrite <= i_RegWrite;
                o_MemtoReg <= i_MemtoReg;
                o_registro_destino <= i_registro_destino;
                o_halt_detected <= i_halt_detected;
                o_data_alu <= i_address_ALU;
                o_data_mem <= wire_dato_mem_acondicionado;
            end
            else begin
                o_RegWrite <= o_RegWrite;
                o_MemtoReg <= o_MemtoReg;
                o_registro_destino <= o_registro_destino;
                o_halt_detected <= o_halt_detected;
                o_data_alu <= o_data_alu;
                o_data_mem <= o_data_mem;
            end 
    end
    end

   
mux
   #(
       .INPUT_OUTPUT_LENGTH (CANT_BITS_ADDR)
   )
   u_mux_address_mem_1
   (
       .i_data_A (i_address_ALU [CANT_BITS_ADDR - 1 : 0]),
       .i_data_B (i_address_debug_unit),
       .i_selector (i_control_address_mem),
       .o_result (wire_address_mem)
 );

output_logic_mem_datos
    #(
        .INPUT_OUTPUT_LENGTH (CANT_BITS_REGISTROS),
        .CANT_BITS_SELECT_BYTES_MEM_DATA (CANT_BITS_SELECT_BYTES_MEM_DATA),
        .WIDTH_WORD (CANT_BITS_REGISTROS)
    )
    u_output_logic_mem_datos_1
    (
        .i_dato_mem (wire_dato_mem_output),
        .i_select_op (i_select_bytes_mem_datos),
        .o_resultado (wire_dato_mem_acondicionado)
    );


input_logic_write_read_mem_datos
    #(
        .CANT_BITS_SELECT_BYTES_MEM_DATA (CANT_BITS_SELECT_BYTES_MEM_DATA),
        .CANT_COLUMNAS_MEM_DATOS (CANT_COLUMNAS_MEM_DATOS)
    )
    u_input_logic_write_read_mem_datos_1
    (
        .i_select_bytes_mem_datos (i_select_bytes_mem_datos),
        .i_write_mem (i_MemWrite),
        .i_read_mem (i_MemRead),
        .i_address_mem_LSB (wire_address_mem [clogb2 (CANT_COLUMNAS_MEM_DATOS - 1) - 1 : 0]),
        .o_write_read_mem (wire_wea_mem)

    );

/**memoria_datos
   #(
        .RAM_WIDTH (RAM_WIDTH_DATOS),
        .RAM_PERFORMANCE (RAM_PERFORMANCE_DATOS),
        .INIT_FILE (INIT_FILE_DATOS),
        .RAM_DEPTH (RAM_DEPTH_DATOS)
    ) 
   u_memoria_datos_1    
   (
     .i_clk (i_clock),
     .i_addr (wire_addr_mem_datos),
     .i_data (wire_datos_in_mem_data),           
     .i_wea (wire_wr_rd_mem_datos),             
     .i_ena (wire_enable_mem),              
     .i_rsta (wire_rsta_mem),             
     .i_regcea (wire_regcea_mem),           
     .i_soft_reset (wire_soft_reset),
     .i_bit_sucio (wire_bit_sucio),      
     .o_data (wire_datos_out_mem_data),           
     .o_reset_ack (wire_soft_reset_ack_datos),
     .o_addr_bit_sucio (wire_addr_control_bit_sucio)    
   );**/


// Control de bit de sucio en memoria de datos.

control_bit_sucio_mem_data
    #(
        .RAM_DEPTH (RAM_DEPTH_DATOS)
    )
    u_control_bit_sucio_mem_data_1
    (
        .i_addr (wire_address_mem),                         
        .i_clk (i_clock),                         
        .i_wea (wire_wea_mem),                            
        .i_ena (i_enable_mem_datos), 
        .i_soft_reset (i_soft_reset),                           
        .i_soft_reset_ack_mem_datos (wire_soft_reset_ack_mem_datos),      
        .o_bit_sucio (wire_bit_sucio) 
    );


  

endmodule
