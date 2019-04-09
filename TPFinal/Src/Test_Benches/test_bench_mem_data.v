 

`timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Test bench del modulo memoria de datos.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////


module test_bench_memoria_datos();
       
   // Parametros
    parameter NB_COL = 4;                           // Specify number of columns (number of bytes)
    parameter COL_WIDTH = 8;                        // Specify column width (byte width, typically 8 or 9)
    parameter RAM_DEPTH = 1024;                     // Specify RAM depth (number of entries)
    parameter RAM_PERFORMANCE = "LOW_LATENCY";      // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    parameter INIT_FILE = "";                        // Specify name/location of RAM initialization file if using one (leave blank if not)
    localparam CANT_BIT_RAM_DEPTH = clogb2(RAM_DEPTH);  
  
   
   //Todo puerto de salida del modulo es un cable.
   //Todo puerto de estimulo o generacion de entrada es un registro.
   
   // Entradas.
    reg clock;                                  // Clock.
    reg [clogb2 (RAM_DEPTH - 1) - 1 : 0] reg_addr;  
    reg [(NB_COL * COL_WIDTH) - 1 : 0] reg_data;                                       
    reg [NB_COL - 1 : 0] reg_wea;                   
    reg reg_ena;                                      
    reg reg_rsta;                                     
    reg reg_regcea;                                  
    reg reg_soft_reset;
    wire wire_soft_reset_ack;
    wire [(NB_COL * COL_WIDTH) - 1 : 0] wire_data;          
   
   
   //  The following function calculates the address width based on specified RAM depth
  function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction
   
   initial    begin
       
       clock = 1'b0;
       reg_wea = 0;
       reg_regcea = 1'b1;
       reg_data = 8'b11011011;
       reg_addr = 11'b0000000;
       reg_ena = 1'b0;
       reg_rsta = 1'b0;
       reg_soft_reset = 1'b1;
      
        
       
       
       
       #20 reg_wea = 15; // Ahora se guarda el dato.
       #20 reg_ena = 1;
       #20 reg_wea = 0; 
       
       #20 reg_data = 32'hFC000000; // Dato a guardar.
       #20 reg_addr = 11'b0000001; // Seteo de direccion de mem.
       #20 reg_wea = 12; // Ahora se guarda el dato.
       #20 reg_wea = 0; 
       
       
       
       #20 reg_data = 8'b00000010; // Dato a guardar.
       #20 reg_addr = 11'b0000010; // Seteo de direccion de mem.
       #20 reg_wea = 0; // Ahora se guarda el dato.
       
       #20 reg_wea = 1; // Ahora se guarda el dato.


       #20 reg_data = 32'h0000AA00; // Dato a guardar.
       #20 reg_addr = 1023; // Seteo de direccion de mem.
       #20 reg_wea = 0;
       
       #20 reg_addr = 11'b0000011; 
       
       #100 reg_soft_reset = 1'b0;
       #30000 reg_soft_reset = 1'b1;
       
       
       #20 reg_wea = 2; // Ahora se guarda el dato.
       
       #20 reg_data = 2; // Dato a guardar.
       #20 reg_addr = 1023; // Seteo de direccion de mem.
       #20 reg_wea = 0;
       
       #100 reg_soft_reset = 1'b0;
       #30000 reg_soft_reset = 1'b1;
       
       
       
       #500000 $finish;
   end
   
   always #2.5 clock=~clock;  // Simulacion de clock.
   


// Modulo para pasarle los estimulos del banco de pruebas.
memoria_datos
   #(
        .NB_COL (NB_COL),                           
        .COL_WIDTH (COL_WIDTH),                        
        .RAM_DEPTH (RAM_DEPTH),                     
        .RAM_PERFORMANCE (RAM_PERFORMANCE),       
        .INIT_FILE (INIT_FILE)
        
    ) 
   u_memoria_datos_1    
   (
     .i_clk (clock),
     .i_addr (reg_addr),
     .i_data (reg_data),
     .i_wea (reg_wea),
     .i_ena (reg_ena),
     .i_rsta (reg_rsta),
     .i_regcea (reg_regcea),
     .i_soft_reset (reg_soft_reset),
     .o_soft_reset_ack (wire_soft_reset_ack),
     .o_data (wire_data)
   );
           
  
endmodule



