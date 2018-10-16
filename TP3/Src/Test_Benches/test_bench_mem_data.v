 

`timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 3. BIP I.
// Test bench del modulo mem_data.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////


module test_bench_memoria_datos();
       
   // Parametros
   parameter RAM_WIDTH = 16;                       // Specify RAM data width
   parameter RAM_DEPTH = 1024;                     // Specify RAM depth (number of entries)
   parameter RAM_PERFORMANCE = "LOW_LATENCY";      // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
   parameter INIT_FILE = "";                        // Specify name/location of RAM initialization file if using one (leave blank if not)
   
   //Todo puerto de salida del modulo es un cable.
   //Todo puerto de estimulo o generacion de entrada es un registro.
   
   // Entradas.
   reg clock;                                  // Clock.
   reg [11-1:0] reg_i_addr;
   reg [RAM_WIDTH-1:0] data_in;                                 
   reg reg_wea;
   //reg reg_regcea; 
   wire [RAM_WIDTH-1:0] wire_o_data;
   
   
   
   initial    begin
       
       clock = 1'b0;
       reg_wea = 1'b0;
       //reg_regcea = 1'b0;
       data_in = 8'b00000000;
       reg_i_addr = 11'b0000000;
        
       //#100 reg_regcea = 1'b1; // Lectura de posicion 0, tiene que haber un 0 porque no se guardo nada todavia.
       
       #100 data_in = 8'b00001111; // Dato a guardar.
       #100 reg_wea = 1'b1; // Ahora se guarda el dato.
       
       #100 reg_wea = 1'b0; 
       
       #160 data_in = 8'b00000001; // Dato a guardar.
       #100 reg_wea = 1'b1; // Ahora se guarda el dato.
       #100 reg_wea = 1'b0; 
       
       
       #100 reg_i_addr = 11'b0000001; // Seteo de direccion de mem.
       #160 data_in = 8'b00000010; // Dato a guardar.
       #100 reg_wea = 1'b1; // Ahora se guarda el dato.
       #100 reg_wea = 1'b0; 
       
       #100 reg_i_addr = 11'b0000000; // Lectura del 1 que se guardo.
       #100 reg_i_addr = 11'b0000001; // Lectura del 2 que se guardo.
       

       
       #1160 data_in = 8'b10000110; // Dato a guardar.      
       
       
       #500000 $finish;
   end
   
   always #2.5 clock=~clock;  // Simulacion de clock.
   


// Modulo para pasarle los estimulos del banco de pruebas.
memoria_datos
   #(
        .RAM_WIDTH (RAM_WIDTH),
        .RAM_PERFORMANCE (RAM_PERFORMANCE),
        //.INIT_FILE (INIT_FILE),
        .RAM_DEPTH (RAM_DEPTH)
    ) 
   u_memoria_datos_1    
   (
     .i_clk (clock),
     .i_addr (reg_i_addr),
     .i_data (data_in),
     .wea (reg_wea),
     //.regcea (reg_regcea),
     .o_data (wire_o_data)
   );
  
endmodule



