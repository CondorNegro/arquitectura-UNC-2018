 

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
   parameter RAM_WIDTH = 32;                       // Specify RAM data width
   parameter RAM_DEPTH = 1024;                     // Specify RAM depth (number of entries)
   parameter RAM_PERFORMANCE = "LOW_LATENCY";      // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
   parameter INIT_FILE = "";                        // Specify name/location of RAM initialization file if using one (leave blank if not)
   
   localparam CANT_BIT_RAM_DEPTH = clogb2(RAM_DEPTH);  
  
   
   //Todo puerto de salida del modulo es un cable.
   //Todo puerto de estimulo o generacion de entrada es un registro.
   
   // Entradas.
   reg clock;                                  // Clock.
   reg [11-1:0] reg_i_addr;
   reg [RAM_WIDTH-1:0] data_in;                                 
   reg reg_wea;
   reg reg_ena;
   reg reg_rsta;
   reg reg_regcea;
   reg reg_soft_reset;
   reg reg_bit_sucio;
   wire wire_o_reset_ack; 
   wire [RAM_WIDTH-1:0] wire_o_data;
   wire [CANT_BIT_RAM_DEPTH-1:0] wire_addr_bit_sucio;
   
   //  The following function calculates the address width based on specified RAM depth
  function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction
   
   initial    begin
       
       clock = 1'b0;
       reg_wea = 1'b0;
       reg_regcea = 1'b1;
       data_in = 8'b11011011;
       reg_i_addr = 11'b0000000;
       reg_ena = 1'b1;
       reg_rsta = 1'b0;
       reg_soft_reset = 1'b1;
       reg_bit_sucio = 1'b0;
        
       //#100 reg_regcea = 1'b1; // Lectura de posicion 0, tiene que haber un 0 porque no se guardo nada todavia.
       
       //#100 data_in = 8'b00001111; // Dato a guardar.
       #20 reg_wea = 1'b1; // Ahora se guarda el dato.
       #10 reg_bit_sucio = 1'b1;
       #20 reg_wea = 1'b0; 
       
       #20 data_in = 8'b00000101; // Dato a guardar.
       #20 reg_i_addr = 11'b0000001; // Seteo de direccion de mem.
       #20 reg_wea = 1'b1; // Ahora se guarda el dato.
       #20 reg_wea = 1'b0; 
       
       
       
       #20 data_in = 8'b00000010; // Dato a guardar.
       #20 reg_i_addr = 11'b0000010; // Seteo de direccion de mem.
       #20 reg_wea = 1'b0; // Ahora se guarda el dato.
       
       #20 reg_wea = 1'b1; // Ahora se guarda el dato.
       #20 data_in = 8'b00000010; // Dato a guardar.
       #20 reg_i_addr = 1023; // Seteo de direccion de mem.
       #20 reg_wea = 1'b0;
       
       #20 reg_i_addr = 11'b0000011; 
       
       #100 reg_soft_reset = 1'b0;
       #30000 reg_soft_reset = 1'b1;
       
       #10 reg_bit_sucio = 1'b0;
       #20 reg_wea = 1'b1; // Ahora se guarda el dato.
       #20 data_in = 8'b00000010; // Dato a guardar.
       #20 reg_i_addr = 1023; // Seteo de direccion de mem.
       #20 reg_wea = 1'b0;
       #100 reg_soft_reset = 1'b0;
       #30000 reg_soft_reset = 1'b1;
       
       
       
       #500000 $finish;
   end
   
   always #2.5 clock=~clock;  // Simulacion de clock.
   


// Modulo para pasarle los estimulos del banco de pruebas.
memoria_datos
   #(
        .RAM_WIDTH (RAM_WIDTH),
        .RAM_PERFORMANCE (RAM_PERFORMANCE),
        .INIT_FILE (INIT_FILE),
        .RAM_DEPTH (RAM_DEPTH)
        
    ) 
   u_memoria_datos_1    
   (
     .i_clk (clock),
     .i_addr (reg_i_addr),
     .i_data (data_in),
     .i_wea (reg_wea),
     .i_ena (reg_ena),
     .i_rsta (reg_rsta),
     .i_regcea (reg_regcea),
     .i_soft_reset (reg_soft_reset),
     .i_bit_sucio (reg_bit_sucio),
     .o_reset_ack (wire_o_reset_ack),
     .o_data (wire_o_data),
     .o_addr_bit_sucio (wire_addr_bit_sucio)
   );
  
endmodule



