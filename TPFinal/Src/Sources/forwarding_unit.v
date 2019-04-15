`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Forwarding unit.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////////////////////

module forwarding_unit
   #(
       
       parameter CANT_BITS_ADDR_REGISTROS = 5,
       parameter CANT_BITS_SELECTOR_MUX = 2
    
    )
   (
       input [CANT_BITS_ADDR_REGISTROS - 1 : 0]  i_rs_ex,
       input [CANT_BITS_ADDR_REGISTROS - 1 : 0]  i_rt_ex,
       input [CANT_BITS_ADDR_REGISTROS - 1 : 0]  i_registro_destino_mem,
       input [CANT_BITS_ADDR_REGISTROS - 1 : 0] i_registro_destino_wb,
       input i_reg_write_mem,
       input i_reg_write_wb,


       output reg [CANT_BITS_SELECTOR_MUX - 1 : 0] o_selector_mux_A,
       output reg [CANT_BITS_SELECTOR_MUX - 1 : 0] o_selector_mux_B     
   );

   

    always@(*) begin
        // MUX A
        if ((i_registro_destino_mem == i_rs_ex) && (i_reg_write_mem == 1'b1)) begin
            o_selector_mux_A = 2;  // Forwarding from MEM        
        end
        else if ((i_registro_destino_wb == i_rs_ex) && (i_reg_write_wb == 1'b1)) begin
            o_selector_mux_A = 1;  // Forwarding from WB
        end
        else begin
            o_selector_mux_A = 0;  // Normal
        end

        // MUX B
        if ((i_registro_destino_mem == i_rt_ex) && (i_reg_write_mem == 1'b1)) begin
            o_selector_mux_B = 2;  // Forwarding from MEM      
        end
        else if ((i_registro_destino_wb == i_rt_ex) && (i_reg_write_wb == 1'b1)) begin
            o_selector_mux_B = 1; // Forwarding from WB 
        end
        else begin
            o_selector_mux_B = 0; // Normal
        end

    end
    
endmodule
