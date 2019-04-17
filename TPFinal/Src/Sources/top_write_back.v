`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// TOP de la etapa de write back.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////////////////////


module top_write_back
   #(
       
       parameter CANT_REGISTROS= 32,
       parameter CANT_BITS_REGISTROS = 32
       
   )
   (
       input i_soft_reset,
       input i_clock,
       input i_enable_pipeline,

       input [clogb2 (CANT_REGISTROS - 1) - 1 : 0] i_registro_destino,
       
       input [CANT_BITS_REGISTROS - 1 : 0] i_data_mem,
       input [CANT_BITS_REGISTROS - 1 : 0] i_data_alu,

       input i_RegWrite,
       input i_MemtoReg,

       input i_halt_detected,
       

       output [clogb2 (CANT_REGISTROS - 1) - 1 : 0] o_registro_destino,
       output o_RegWrite,
       output [CANT_BITS_REGISTROS - 1 : 0] o_data_write,
       output reg o_halt_detected,


       output o_led
   );



    //  The following function calculates the address width based on specified RAM depth
    function integer clogb2;
        input integer depth;
            for (clogb2=0; depth>0; clogb2=clogb2+1)
                depth = depth >> 1;
    endfunction


    assign o_registro_destino = i_registro_destino;
    assign o_RegWrite = i_RegWrite;
    

    always@(negedge i_clock) begin
        if (~i_soft_reset) begin   
            o_halt_detected <= 1'b0;   
        end
        else begin
            if (i_enable_pipeline) begin
                o_halt_detected <= i_halt_detected;
            end
            else begin
                o_halt_detected <= o_halt_detected;
            end 
        end
    end




mux
   #(
       .INPUT_OUTPUT_LENGTH (CANT_BITS_REGISTROS)
    )
    u_mux_1
   (
       .i_data_A (i_data_mem),
       .i_data_B (i_data_alu),
       .i_selector (~i_MemtoReg),
       .o_result (o_data_write)
    );



  

endmodule
