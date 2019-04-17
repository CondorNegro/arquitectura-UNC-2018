`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Input logic para la memoria de datos.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////////////////////


module input_logic_mem_datos
   #(
       
       parameter CANT_BITS_SELECT_BYTES_MEM_DATA = 3,
       parameter CANT_COLUMNAS_MEM_DATOS = 4,
       parameter CANT_BITS_DATO_MEM = 32
        
 
   )
   (
        input [CANT_BITS_SELECT_BYTES_MEM_DATA - 1 : 0] i_select_bytes_mem_datos,
        input i_write_mem,
        input i_read_mem,
        input [clogb2 (CANT_COLUMNAS_MEM_DATOS - 1) - 1 : 0] i_address_mem_LSB,
        input [CANT_BITS_DATO_MEM - 1 : 0] i_dato_mem,
        input i_enable_etapa,
        output reg [CANT_BITS_DATO_MEM - 1 : 0] o_dato_mem,
        output reg [CANT_COLUMNAS_MEM_DATOS - 1 : 0] o_write_read_mem
   );

  
    
    //  The following function calculates the address width based on specified RAM depth
    function integer clogb2;
        input integer depth;
            for (clogb2=0; depth>0; clogb2=clogb2+1)
                depth = depth >> 1;
    endfunction

     


    always@(*) begin
        if (i_enable_etapa) begin
            if (i_read_mem) begin
                o_write_read_mem = 0; // Lectura.
                o_dato_mem = i_dato_mem;
            end
            else if (i_write_mem) begin // Escritura.
                case (i_select_bytes_mem_datos [CANT_BITS_SELECT_BYTES_MEM_DATA - 2 : 0])
                    3:
                        begin //Word
                            o_write_read_mem = {CANT_COLUMNAS_MEM_DATOS {1'b1}};
                            o_dato_mem = i_dato_mem;
                        end
                    2:
                        begin //Halfword
                            if (i_address_mem_LSB [clogb2 (CANT_COLUMNAS_MEM_DATOS - 1) - 1]) begin
                                o_write_read_mem = 4'b1100;
                                o_dato_mem = i_dato_mem << ((CANT_BITS_DATO_MEM / CANT_COLUMNAS_MEM_DATOS) * 2);
                            end
                            else begin
                                o_write_read_mem = 4'b0011;
                                o_dato_mem = i_dato_mem;
                            end     
                        end
                    1:
                        begin //Byte
                            o_write_read_mem = 1 << i_address_mem_LSB;
                            o_dato_mem = i_dato_mem << ((CANT_BITS_DATO_MEM / CANT_COLUMNAS_MEM_DATOS) * i_address_mem_LSB); 
                        end
                    
                    default:
                        begin
                            o_write_read_mem = {CANT_COLUMNAS_MEM_DATOS {1'b0}};
                            o_dato_mem = i_dato_mem;
                        end
                endcase
            end
            else begin
                o_write_read_mem = 0;
                o_dato_mem = i_dato_mem;
            end
        end
        else begin
            o_write_read_mem = o_write_read_mem; // Lectura.
            o_dato_mem = o_dato_mem;
        end
    end

  

endmodule
