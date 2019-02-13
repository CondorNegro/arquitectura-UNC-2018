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
    i_addr,  // Address bus, width determined from RAM_DEPTH
    i_clk,                            // Clock
    wea,                              // Write enable
    ena,                            // RAM Enable, for additional power savings, disable port when not in use (1)
    i_soft_reset_ack_mem_datos,
    o_bit_sucio
    
    );
  
  
  parameter RAM_DEPTH = 1024;                  // Specify RAM depth (number of entries)
  localparam CANT_BIT_RAM_DEPTH = clogb2(RAM_DEPTH);  

  
  input [CANT_BIT_RAM_DEPTH-1:0] i_addr;  // Address bus, width determined from RAM_DEPTH
  
  input i_clk;                            // Clock
  input wea;                              // Write enable
  input ena;                            // RAM Enable, for additional power savings, disable port when not in use (1)
  input i_soft_reset_ack_mem_datos;
  output o_bit_sucio;
  
  reg [RAM_DEPTH-1 : 0] bit_sucio;
  
  
 
  
  
  

  always @(posedge i_clk) begin
    if (~i_soft_reset_ack_mem_datos) begin
        bit_sucio <= 0;
    end
    else begin
        if (ena && wea) begin
            bit_sucio[i_addr] <= 1;
        end
        else begin
            bit_sucio <= bit_sucio;
        end
    end
  end
  
  assign o_bit_sucio = bit_sucio[i_addr];
endmodule
