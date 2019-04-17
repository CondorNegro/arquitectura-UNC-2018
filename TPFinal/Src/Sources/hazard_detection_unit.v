`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Hazard detection unit.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////////////////////

module hazard_detection_unit
   #(
       
       parameter CANT_BITS_ADDR_REGISTROS = 5
    
    )
   (
       input [CANT_BITS_ADDR_REGISTROS - 1 : 0]  i_rs_id,
       input [CANT_BITS_ADDR_REGISTROS - 1 : 0]  i_rt_id,
       input [CANT_BITS_ADDR_REGISTROS - 1 : 0]  i_registro_destino_ex,
       input i_read_mem_ex,
       input i_disable_for_exception,
       input i_enable_etapa, 

       output reg o_led, 
       output reg o_bit_burbuja    
   );

    
   

    always@(*) begin
        if (i_enable_etapa) begin
            if (i_read_mem_ex) begin // Es load
                if (((i_registro_destino_ex == i_rs_id) || (i_registro_destino_ex == i_rt_id)) && (~i_disable_for_exception)) begin
                    o_bit_burbuja = 1'b1;
                    o_led = 0;
                end
                else begin
                    o_bit_burbuja = 1'b0;
                    o_led = 1;
                end
            end
            else begin
            o_bit_burbuja = 1'b0;
            o_led = 1;
            end
        end
        else begin
            o_bit_burbuja = o_bit_burbuja;
            o_led = o_led;
        end
    end
    
endmodule