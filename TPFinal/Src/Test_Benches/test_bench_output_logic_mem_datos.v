 

`timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Test bench del modulo de la logica de salida del dato leido de la memoria de datos.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////


module test_bench_output_logic_mem_datos();
       
   // Parametros
    parameter INPUT_OUTPUT_LENGTH = 32;
    parameter CANT_BITS_SELECT_BYTES_MEM_DATA = 3;
    
    reg [INPUT_OUTPUT_LENGTH - 1 : 0] reg_dato_mem;
    reg [CANT_BITS_SELECT_BYTES_MEM_DATA - 1 : 0] reg_select_op;
    wire [INPUT_OUTPUT_LENGTH - 1 : 0] wire_resultado;
   
   //  The following function calculates the address width based on specified RAM depth
  function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction
   
   
   initial begin
       reg_dato_mem = 1;
       reg_select_op = 0;
       // Unsigned.
       #20 reg_select_op = 1;
       #20 reg_dato_mem = 32'h000000F0;
       #20 reg_dato_mem = 1;
       // Signed.
       #20 reg_select_op = 5;
       #20 reg_dato_mem = 32'h000000F0;


       #100 $finish;
   end
   
   


// Modulo para pasarle los estimulos del banco de pruebas.
output_logic_mem_datos
    #(
        .INPUT_OUTPUT_LENGTH (INPUT_OUTPUT_LENGTH),
        .CANT_BITS_SELECT_BYTES_MEM_DATA (CANT_BITS_SELECT_BYTES_MEM_DATA)
    )
    u_output_logic_mem_datos_1
    (
        .i_dato_mem (reg_dato_mem),
        .i_select_op (reg_select_op),
        .o_resultado (wire_resultado)
    );
  
endmodule



