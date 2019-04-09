`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Output logic de la memoria de datos.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////////////////////


module output_logic_mem_datos
   #(
       
       parameter INPUT_OUTPUT_LENGTH = 32,
       parameter CANT_BITS_SELECT_BYTES_MEM_DATA = 3,
       parameter CANT_COLUMNAS_MEM_DATOS = 4
 
   )
   (
        input [INPUT_OUTPUT_LENGTH - 1 : 0] i_dato_mem,
        input [CANT_BITS_SELECT_BYTES_MEM_DATA - 1 : 0] i_select_op,
        input [clogb2 (CANT_COLUMNAS_MEM_DATOS - 1) - 1 : 0] i_address_mem_LSB,
        output reg [INPUT_OUTPUT_LENGTH - 1 : 0] o_resultado
   );

    reg [INPUT_OUTPUT_LENGTH - 1 : 0] reg_dato_mem_shifted;

    //  The following function calculates the address width based on specified RAM depth
    function integer clogb2;
        input integer depth;
            for (clogb2=0; depth>0; clogb2=clogb2+1)
                depth = depth >> 1;
    endfunction

    

    always@(*) begin
        if (i_select_op [CANT_BITS_SELECT_BYTES_MEM_DATA - 1]) begin // Signado
           case (i_select_op [CANT_BITS_SELECT_BYTES_MEM_DATA - 2 : 0]) 
                1://Byte
                    begin
                        reg_dato_mem_shifted = i_dato_mem >> (i_address_mem_LSB * (INPUT_OUTPUT_LENGTH / CANT_COLUMNAS_MEM_DATOS));
                        o_resultado = { { ((INPUT_OUTPUT_LENGTH / 4) * 3) {reg_dato_mem_shifted [INPUT_OUTPUT_LENGTH / 4 - 1] } }, reg_dato_mem_shifted [INPUT_OUTPUT_LENGTH / 4 - 1 : 0] };
                    end
                2: //Halfword
                    begin
                        reg_dato_mem_shifted = i_dato_mem >> (i_address_mem_LSB [clogb2 (CANT_COLUMNAS_MEM_DATOS - 1) - 1] * (INPUT_OUTPUT_LENGTH / (CANT_COLUMNAS_MEM_DATOS / 2))); 
                        o_resultado = { { (INPUT_OUTPUT_LENGTH / 2) {reg_dato_mem_shifted [INPUT_OUTPUT_LENGTH / 2 - 1] } }, reg_dato_mem_shifted [INPUT_OUTPUT_LENGTH / 2 - 1 : 0] };
                        
                    end
                3: //Word
                    begin
                        reg_dato_mem_shifted = i_dato_mem;
                        o_resultado = reg_dato_mem_shifted;
                    end
                default:
                    begin
                        reg_dato_mem_shifted = i_dato_mem;
                        o_resultado = reg_dato_mem_shifted;
                    end
           endcase
        end
        else begin // Unsigned
            case (i_select_op [CANT_BITS_SELECT_BYTES_MEM_DATA - 2 : 0]) 
                1://Byte
                    begin
                      reg_dato_mem_shifted = i_dato_mem >> (i_address_mem_LSB  * (INPUT_OUTPUT_LENGTH / CANT_COLUMNAS_MEM_DATOS));
                      o_resultado = reg_dato_mem_shifted;
                    end
                2: //Halfword
                    begin
                        reg_dato_mem_shifted = i_dato_mem >> (i_address_mem_LSB [clogb2 (CANT_COLUMNAS_MEM_DATOS - 1) - 1] * (INPUT_OUTPUT_LENGTH / (CANT_COLUMNAS_MEM_DATOS / 2))); 
                        o_resultado = reg_dato_mem_shifted;
                    end
                3: //Word
                    begin
                        reg_dato_mem_shifted = i_dato_mem;
                        o_resultado = reg_dato_mem_shifted;
                    end
                default:
                    begin
                        reg_dato_mem_shifted = i_dato_mem;
                        o_resultado = reg_dato_mem_shifted;
                    end
            endcase
        end
    end

  

endmodule
