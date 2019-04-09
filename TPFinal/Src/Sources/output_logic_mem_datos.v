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
       parameter CANT_BITS_SELECT_BYTES_MEM_DATA = 3
 
   )
   (
        input [INPUT_OUTPUT_LENGTH - 1 : 0] i_dato_mem,
        input [CANT_BITS_SELECT_BYTES_MEM_DATA - 1 : 0] i_select_op,
        output reg [INPUT_OUTPUT_LENGTH - 1 : 0] o_resultado
   );

  

    


    always@(*) begin
        if (i_select_op [CANT_BITS_SELECT_BYTES_MEM_DATA - 1]) begin // Signado
           case (i_select_op [CANT_BITS_SELECT_BYTES_MEM_DATA - 2 : 0]) 
                1://Byte
                    begin
                      o_resultado = { { ((INPUT_OUTPUT_LENGTH / 4) * 3) {i_dato_mem[INPUT_OUTPUT_LENGTH / 4 - 1]} }, i_dato_mem [INPUT_OUTPUT_LENGTH / 4 - 1 : 0]};
                    end
                2: //Halfword
                    begin
                      o_resultado = { { (INPUT_OUTPUT_LENGTH / 2) {i_dato_mem[INPUT_OUTPUT_LENGTH / 2 - 1]} }, i_dato_mem [INPUT_OUTPUT_LENGTH / 2 - 1 : 0]};
                    end
                3: //Word
                    begin
                      o_resultado = i_dato_mem;
                    end
                default:
                    begin
                       o_resultado = i_dato_mem;
                    end
           endcase
        end
        else begin // Unsigned
           o_resultado = i_dato_mem;
        end
    end

  

endmodule
