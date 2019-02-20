`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Control del bit de sucio en la memoria de datos.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////////////////////

module control_bit_sucio_mem_data
    (
    i_addr,                         // Address bus, width determined from RAM_DEPTH
    i_clk,                          // Clock
    i_wea,                          // Write enable
    i_ena,                          // RAM Enable, for additional power savings, disable port when not in use (1)
    i_soft_reset,                   // General soft reset.
    i_soft_reset_ack_mem_datos,     // Soft reset ack de la memoria de datos.
    o_bit_sucio                     // Bit de sucio solicitado.
    );
  
  
  parameter RAM_DEPTH = 1024;                           // Specify RAM depth (number of entries)
  localparam CANT_BIT_RAM_DEPTH = clogb2(RAM_DEPTH);  

  
  input [CANT_BIT_RAM_DEPTH-1:0] i_addr;  
  input i_clk;                           
  input i_wea;                              
  input i_ena;
  input i_soft_reset;                            
  input i_soft_reset_ack_mem_datos;
  output o_bit_sucio;
  
  reg [RAM_DEPTH - 1 : 0] bit_sucio;
  
  //  The following function calculates the address width based on specified RAM depth
  function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction
 
 always @(posedge i_clk) begin
    if ((~i_soft_reset_ack_mem_datos) | (~i_soft_reset)) begin // Se esta reseteando la memoria de datos.
        bit_sucio <= 0;
    end
    else begin
        if (i_ena && i_wea) begin
            bit_sucio[i_addr] <= 1;
        end
        else begin
            bit_sucio <= bit_sucio;
        end
    end
  end
  
  assign o_bit_sucio = bit_sucio[i_addr];
endmodule
