 

`timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 3. BIP I.
// Test bench del modulo memoria_programa.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////


module test_bench_mem_programa();
       
   // Parametros
   parameter RAM_WIDTH = 16;                       // Specify RAM data width
   parameter RAM_DEPTH = 2048;                     // Specify RAM depth (number of entries)
   parameter RAM_PERFORMANCE = "LOW_LATENCY";      // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
   parameter INIT_FILE = "init_ram_file.txt";                       // Specify name/location of RAM initialization file if using one (leave blank if not)
   
   //Todo puerto de salida del modulo es un cable.
   //Todo puerto de estimulo o generacion de entrada es un registro.
   
   // Entradas.
   reg clock;                                  // Clock.
   reg [11 - 1 : 0] reg_i_addr;
   //reg [RAM_WIDTH-1:0] data_in;                                 
   //reg reg_wea;
   //reg reg_regcea; 
   wire [RAM_WIDTH - 1 : 0] wire_o_data;
   
   
   
   initial    begin
       
       clock = 1'b0;
       reg_i_addr = 11'b0000000;       
       #102 reg_i_addr = 11'b0000001; // Seteo de direccion de mem.
       #100 reg_i_addr = 11'b0000010; 
       #100 reg_i_addr = 11'b0000011; 
       #5000 $finish;
   end
   
   always #2.5 clock=~clock;  // Simulacion de clock.
   


// Modulo para pasarle los estimulos del banco de pruebas.
memoria_programa
   #(
        .RAM_WIDTH (RAM_WIDTH),
        .RAM_PERFORMANCE (RAM_PERFORMANCE),
        .INIT_FILE (INIT_FILE),
        .RAM_DEPTH (RAM_DEPTH)
    ) 
   u_memoria_programa_1    
   (
     .i_clk (clock),
     .i_addr (reg_i_addr),
     //.i_data (data_in),
     //.wea (reg_wea),
     //.regcea (reg_regcea),
     .o_data (wire_o_data)
   );
  
endmodule



