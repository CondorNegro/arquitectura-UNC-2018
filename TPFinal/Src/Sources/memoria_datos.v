`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Memoria de datos.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////////////////////




//  Xilinx Single Port Byte-Write Read First RAM
//  This code implements a parameterizable single-port byte-write read-first memory where when data
//  is written to the memory, the output reflects the prior contents of the memory location.
//  If a reset or enable is not necessary, it may be tied off or removed from the code.
//  Modify the parameters for the desired RAM characteristics.

module memoria_datos 
  #(
  parameter NB_COL = 4,                           // Specify number of columns (number of bytes)
  parameter COL_WIDTH = 8,                        // Specify column width (byte width, typically 8 or 9)
  parameter RAM_DEPTH = 1024,                     // Specify RAM depth (number of entries)
  parameter RAM_PERFORMANCE = "LOW_LATENCY",      // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
  parameter INIT_FILE = ""                        // Specify name/location of RAM initialization file if using one (leave blank if not)
  )
  (
  input [clogb2 (RAM_DEPTH - 1) - 1 : 0] i_addr,  // Address bus, width determined from RAM_DEPTH
  input [(NB_COL * COL_WIDTH) - 1 : 0] i_data,    // RAM input data
  input i_clk,                                    // Clock
  input [NB_COL - 1 : 0] i_wea,                   // Byte-write enable
  input i_ena,                                      // RAM Enable, for additional power savings, disable port when not in use
  input i_rsta,                                     // Output reset (does not affect memory contents)
  input i_regcea,                                   // Output register enable
  input i_soft_reset,
  output reg o_soft_reset_ack,
  output [(NB_COL * COL_WIDTH) - 1 : 0] o_data           // RAM output data
  );

  reg [(NB_COL *COL_WIDTH) -1 : 0] BRAM [RAM_DEPTH - 1 : 0];
  reg [(NB_COL *COL_WIDTH) -1 : 0] ram_data = {(NB_COL * COL_WIDTH){1'b0}};
  reg [31 : 0] reg_contador;

  // The following code either initializes the memory values to a specified file or to all zeros to match hardware
  generate
    if (INIT_FILE != "") begin: use_init_file
      initial
        $readmemh(INIT_FILE, BRAM, 0, RAM_DEPTH-1);
    end else begin: init_bram_to_zero
      integer ram_index;
      initial
        for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
          BRAM[ram_index] = {(COL_WIDTH * NB_COL) {1'b0}};
    end
  endgenerate

  always @(posedge i_clk) begin
    if (~i_soft_reset) begin // Reset de memoria.
          BRAM [reg_contador] <= {(COL_WIDTH * NB_COL) {1'b0}};
          ram_data <= 0;
          if (reg_contador == (RAM_DEPTH - 1)) begin
            reg_contador <= reg_contador;
            o_soft_reset_ack <= 0;
          end
          else begin
            reg_contador <= reg_contador + 1;
            o_soft_reset_ack <= 1;
          end
    end
    else begin
            reg_contador <= 0;
            o_soft_reset_ack <= 1;
            
            if (i_ena) begin
                ram_data <= BRAM[i_addr];
            end
            else begin
                ram_data <= ram_data;
            end
    end
  end

  generate
  genvar i;
     for (i = 0; i < NB_COL; i = i+1) begin: byte_write
       always @(posedge i_clk)
            if (i_ena && i_soft_reset) // Habilitada y sin reset.
                if (i_wea[i])
                    BRAM[i_addr][(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= i_data[(i+1)*COL_WIDTH-1:i*COL_WIDTH];
      end
  endgenerate

  //  The following code generates HIGH_PERFORMANCE (use output register) or LOW_LATENCY (no output register)
  generate
    if (RAM_PERFORMANCE == "LOW_LATENCY") begin: no_output_register

      // The following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
       assign o_data = ram_data;

    end else begin: output_register

      // The following is a 2 clock cycle read latency with improve clock-to-out timing

      reg [(NB_COL*COL_WIDTH)-1:0] o_data_reg = {(NB_COL*COL_WIDTH){1'b0}};

      always @(posedge i_clk)
        if (i_rsta)
          o_data_reg <= {(NB_COL*COL_WIDTH){1'b0}};
        else if (i_regcea)
          o_data_reg <= ram_data;

      assign o_data = o_data_reg;

    end
  endgenerate

  //  The following function calculates the address width based on specified RAM depth
  function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction

endmodule

// The following is an instantiation template for xilinx_single_port_byte_write_ram_read_first
/*
  //  Xilinx Single Port Byte-Write Read First RAM
  xilinx_single_port_byte_write_ram_read_first #(
    .NB_COL(4),                           // Specify number of columns (number of bytes)
    .COL_WIDTH(9),                        // Specify column width (byte width, typically 8 or 9)
    .RAM_DEPTH(1024),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE("")                        // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) your_instance_name (
    .i_addr(i_addr),     // Address bus, width determined from RAM_DEPTH
    .i_data(i_data),       // RAM input data, width determined from NB_COL*COL_WIDTH
    .i_clk(i_clk),       // Clock
    .i_wea(i_wea),         // Byte-write enable, width determined from NB_COL
    .ena(ena),         // RAM Enable, for additional power savings, disable port when not in use
    .i_rsta(i_rsta),       // Output reset (does not affect memory contents)
    .i_regcea(i_regcea),   // Output register enable
    .o_data(o_data)      // RAM output data, width determined from NB_COL*COL_WIDTH
  );
*/
							
							
						
						