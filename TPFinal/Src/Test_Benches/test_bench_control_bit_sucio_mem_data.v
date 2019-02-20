 

`timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Test bench del modulo control del bit sucio de la memoria de datos.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////


module test_bench_control_bit_sucio_mem_data();
       
   // Parametros
   parameter RAM_DEPTH = 1024;                     // Specify RAM depth (number of entries)
   localparam CANT_BIT_RAM_DEPTH = clogb2(RAM_DEPTH);
   //Todo puerto de salida del modulo es un cable.
   //Todo puerto de estimulo o generacion de entrada es un registro.
   
   // Entradas.
   reg clock;                                  // Clock.
   reg [CANT_BIT_RAM_DEPTH - 1 : 0] reg_i_addr;                                
   reg reg_wea;
   reg reg_ena;
   reg reg_soft_reset_ack;
   reg reg_soft_reset;
   wire wire_o_bit_sucio;
   
   //  The following function calculates the address width based on specified RAM depth
  function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction
   
   
   initial    begin
       
       clock = 1'b0;
       reg_wea = 1'b0;
       reg_i_addr = 0;
       reg_ena = 1'b1;
       reg_soft_reset_ack = 1'b1;
       reg_soft_reset = 1'b1;

       #10 reg_soft_reset = 1'b0;
       #10 reg_soft_reset = 1'b1;
        
       
       #20 reg_wea = 1'b1; // Ahora se coloca un 1 en la direccion cero en el registro de los bits sucios.
       
       #20 reg_wea = 1'b0; 
       
       #20 reg_i_addr = 1; // Seteo de direccion.
       
       #20 reg_wea = 1'b1; 
       #20 reg_wea = 1'b0; 
       
       #20 reg_i_addr = 2; // Seteo de direccion.
       #20 reg_wea = 1'b1;
       #20 reg_wea = 1'b0; 
       
       
       #20 reg_i_addr = 3; 
       
       #100 reg_soft_reset_ack = 1'b0;
       #30000 reg_soft_reset_ack = 1'b1;
       
       
       
       #500000 $finish;
   end
   
   always #2.5 clock=~clock;  // Simulacion de clock.
   


// Modulo para pasarle los estimulos del banco de pruebas.
control_bit_sucio_mem_data
   #(
        .RAM_DEPTH (RAM_DEPTH)   
    ) 
   u_control_bit_sucio_mem_data_1    
   (
     .i_clk (clock),
     .i_addr (reg_i_addr),
     .i_wea (reg_wea),
     .i_ena (reg_ena),
     .i_soft_reset_ack_mem_datos (reg_soft_reset_ack),
     .i_soft_reset (reg_soft_reset),
     .o_bit_sucio (wire_o_bit_sucio)
   );
  
endmodule



