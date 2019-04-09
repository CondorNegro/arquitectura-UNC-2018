 

`timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Test bench del modulo de la logica de entrada del write y el read de la memoria
// de datos.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////


module test_bench_input_logic_write_read_mem_datos();
       
   // Parametros
    parameter CANT_BITS_SELECT_BYTES_MEM_DATA = 3;
    parameter CANT_COLUMNAS_MEM_DATOS = 4;
   
   // Entradas.
    reg [CANT_BITS_SELECT_BYTES_MEM_DATA - 1 : 0] reg_select_bytes_mem_datos;
    reg reg_write_mem;
    reg reg_read_mem;
    reg [clogb2 (CANT_COLUMNAS_MEM_DATOS - 1) - 1 : 0] reg_address_mem_LSB;
    wire [CANT_COLUMNAS_MEM_DATOS - 1 : 0] wire_wea;
   
   //  The following function calculates the address width based on specified RAM depth
  function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction
   
   
   initial begin
       reg_select_bytes_mem_datos = 0;
       reg_write_mem = 0;
       reg_read_mem = 0;
       reg_address_mem_LSB = 00;

        // Pruebo read.
       #20 reg_read_mem = 1;

        // Pruebo escribir word.
       #20 reg_read_mem = 0;
       #20 reg_select_bytes_mem_datos = 3;
       #20 reg_write_mem = 1;
       #20 reg_write_mem = 0;

        // Pruebo escribir halfword en parte MS de linea de memoria.
        #20 reg_address_mem_LSB = 10; 
        #20 reg_select_bytes_mem_datos = 2;
        #20 reg_write_mem = 1;
        #20 reg_write_mem = 0;

        // Pruebo escribir byte MS de la linea de memoria.
        #20 reg_address_mem_LSB = 11; 
        #20 reg_select_bytes_mem_datos = 1;
        #20 reg_write_mem = 1;
        #20 reg_write_mem = 0;

        // Pruebo escribir segundo byte de la linea de memoria.
        #20 reg_address_mem_LSB = 01; 
        #20 reg_select_bytes_mem_datos = 1;
        #20 reg_write_mem = 1;
        #20 reg_write_mem = 0;       
       #500000 $finish;
   end
   
   


// Modulo para pasarle los estimulos del banco de pruebas.
input_logic_write_read_mem_datos
    #(
        .CANT_BITS_SELECT_BYTES_MEM_DATA (CANT_BITS_SELECT_BYTES_MEM_DATA),
        .CANT_COLUMNAS_MEM_DATOS (CANT_COLUMNAS_MEM_DATOS)
    )
    u_input_logic_write_read_mem_datos_1
    (
        .i_select_bytes_mem_datos (reg_select_bytes_mem_datos),
        .i_write_mem (reg_write_mem),
        .i_read_mem (reg_read_mem),
        .i_address_mem_LSB (reg_address_mem_LSB),
        .o_write_read_mem (wire_wea)

    );
  
endmodule



