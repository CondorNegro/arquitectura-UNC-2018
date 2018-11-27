 

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
   parameter RAM_PERFORMANCE = "HIGH_PERFORMANCE";      // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
   parameter INIT_FILE = "";                       // Specify name/location of RAM initialization file if using one (leave blank if not)
   parameter CANT_BIT_RAM_DEPTH = 11;
   
   //Todo puerto de salida del modulo es un cable.
   //Todo puerto de estimulo o generacion de entrada es un registro.
   
   // Entradas.
   reg clock;                                  // Clock.
   reg [11 - 1 : 0] reg_i_addr;
   reg [RAM_WIDTH - 1 : 0] reg_dina;
   reg reg_softreset;  
   //reg [RAM_WIDTH-1:0] data_in;
   //reg reg_wea;
   //reg reg_regcea;
   wire [RAM_WIDTH - 1 : 0] wire_o_data;
   wire wire_ack;
   
   
   
   initial    begin
       
       clock = 1'b0;
       reg_i_addr = 0;
       reg_dina = 0;
       reg_softreset = 1;
       
       #10000 reg_softreset = 1'b0;
       #10000 reg_softreset = 1'b1;
       
       #100000 reg_softreset = 1'b0;
       #100000 reg_softreset = 1'b1;
       
        
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
        .RAM_DEPTH (RAM_PERFORMANCE),
        .RAM_PERFORMANCE (RAM_PERFORMANCE),
        .INIT_FILE (INIT_FILE),
        .CANT_BIT_RAM_DEPTH (CANT_BIT_RAM_DEPTH)
    ) 
   u_memoria_programa_1    
   (
     .i_clk (clock),
     .i_addr (reg_i_addr),
     .dina (reg_dina),
     .wea (0),
     .ena (1),
     .rsta (0),
     .regcea (1),
     .soft_reset (reg_softreset),
     .o_data (wire_o_data),
     .o_reset_ack (wire_ack)
   );
  
endmodule



