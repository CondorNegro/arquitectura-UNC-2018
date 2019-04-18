`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Register file.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////////////////////


module register_file
    #(
        parameter CANTIDAD_REGISTROS = 32,
        parameter CANTIDAD_BITS_REGISTROS = 32,
        parameter CANTIDAD_BITS_ADDRESS_REGISTROS = 5
    )
    (
        input i_clock,
        input i_soft_reset,
        input [CANTIDAD_BITS_ADDRESS_REGISTROS - 1 : 0] i_reg_A,
        input [CANTIDAD_BITS_ADDRESS_REGISTROS - 1 : 0] i_reg_B,
        input [CANTIDAD_BITS_ADDRESS_REGISTROS - 1 : 0] i_reg_Write,
        input [CANTIDAD_BITS_REGISTROS - 1 : 0] i_data_write,
        input i_control_write,
        input [CANTIDAD_BITS_ADDRESS_REGISTROS - 1 : 0] i_reg_read_from_debug_unit,
        input i_enable_etapa,
        input i_enable_pipeline,
        output reg [CANTIDAD_BITS_REGISTROS - 1 : 0] o_reg_data_to_debug_unit,
        output reg [CANTIDAD_BITS_REGISTROS - 1 : 0] o_data_A,
        output reg [CANTIDAD_BITS_REGISTROS - 1 : 0] o_data_B,
        output reg o_led
    );


reg [CANTIDAD_REGISTROS -  1 : 0] registros [CANTIDAD_BITS_REGISTROS - 1 : 0];
reg [CANTIDAD_BITS_ADDRESS_REGISTROS - 1 : 0] reg_contador_reset;

// Inicializo registros.
generate
    integer indice_registro;		
	initial
    for (indice_registro = 0; indice_registro < CANTIDAD_REGISTROS; indice_registro = indice_registro + 1)
        registros[indice_registro] = {CANTIDAD_BITS_REGISTROS {1'b0} };
endgenerate




always@( negedge i_clock) begin
    // Se resetean los registros.
   if (~ i_soft_reset) begin
       o_led <= 0;
       o_data_A <= 0;
       o_data_B <= 0;
       o_reg_data_to_debug_unit <= 0;
   end
   else begin
        o_reg_data_to_debug_unit <= registros [i_reg_read_from_debug_unit];
        if (i_enable_pipeline) begin  
            o_data_A <= registros [i_reg_A];
            o_data_B <= registros [i_reg_B];
        end
        else begin
            o_data_A <= o_data_A;
            o_data_B <= o_data_B;
        end
        if (registros[0] != 0) begin // Valor en R1 modificado.
            o_led <= 1'b1;
        end
        else begin
            o_led <= 1'b0; 
        end
    end
end

always@( posedge i_clock) begin // Escritura de registros.
    if (~i_soft_reset) begin
        registros[reg_contador_reset] <= 0;
        if (reg_contador_reset < CANTIDAD_REGISTROS -  1) begin
            reg_contador_reset <= reg_contador_reset + 1;
        end
        else begin
            reg_contador_reset <= reg_contador_reset;
        end
    end
    else begin
        reg_contador_reset <= 0;
        
        if ((i_control_write == 1'b1) && i_enable_etapa) begin
            registros [i_reg_Write] <= i_data_write;
        end
        else begin
            registros [i_reg_Write] <= registros [i_reg_Write];
        end
    end
    
end

endmodule
