`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Base de datos.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////////////////////


module database
   #(
       parameter ADDR_LENGTH = 11,
       parameter LONGITUD_INSTRUCCION = 32,
       parameter CANT_BITS_CONTROL = 3
   )
   (
       input i_clock,
       input i_soft_reset,
       input [CANT_BITS_CONTROL - 1 : 0] i_control,

       input [ADDR_LENGTH - 1 : 0] i_contador_ciclos, 

       // Intruction Fetch.
       input [ADDR_LENGTH - 1 : 0] i_pc,
       input [ADDR_LENGTH - 1 : 0] i_pc_plus_cuatro,
       input [LONGITUD_INSTRUCCION - 1 : 0] i_instruction_fetch,

       output reg o_leds,
       output reg [LONGITUD_INSTRUCCION - 1 : 0] o_dato

   );

    reg [ADDR_LENGTH - 1 : 0] reg_contador_ciclos;
    reg [ADDR_LENGTH - 1 : 0] reg_pc;
    reg [ADDR_LENGTH - 1 : 0] reg_pc_plus_cuatro;
    reg [LONGITUD_INSTRUCCION - 1 : 0] reg_instruction_fetch;

  always @(posedge i_clock) begin
    if (~ i_soft_reset) begin
        reg_pc <= 0;
        reg_pc_plus_cuatro <= 4;
        reg_instruction_fetch <= 0;
        reg_contador_ciclos <= 0;
        o_leds<=0;
    end
    else begin
    
        if (i_control == 1) begin
            reg_pc <= i_pc;
            reg_pc_plus_cuatro <= i_pc_plus_cuatro;
            reg_instruction_fetch <= i_instruction_fetch;
            reg_contador_ciclos <= i_contador_ciclos;
            o_dato <= 0;
        end
        else if (i_control == 2) begin
            reg_pc <= reg_pc;
            reg_pc_plus_cuatro <= reg_pc_plus_cuatro;
            reg_instruction_fetch <= reg_instruction_fetch;
            reg_contador_ciclos <= reg_contador_ciclos;
            o_dato <= reg_pc;
        end
        else if (i_control == 4) begin
            reg_pc <= reg_pc;
            reg_pc_plus_cuatro <= reg_pc_plus_cuatro;
            reg_instruction_fetch <= reg_instruction_fetch;
            reg_contador_ciclos <= reg_contador_ciclos;
            o_dato <= reg_pc_plus_cuatro;
        end
        else if (i_control == 5) begin
            reg_pc <= reg_pc;
            reg_pc_plus_cuatro <= reg_pc_plus_cuatro;
            reg_instruction_fetch <= reg_instruction_fetch;
            reg_contador_ciclos <= reg_contador_ciclos;
            o_dato <= reg_instruction_fetch;
        end
        else if (i_control > 3) begin
            reg_pc <= reg_pc;
            reg_pc_plus_cuatro <= reg_pc_plus_cuatro;
            reg_instruction_fetch <= reg_instruction_fetch;
            reg_contador_ciclos <= reg_contador_ciclos;
            o_dato <= reg_contador_ciclos;
            if (reg_contador_ciclos>0) begin
                o_leds<=1;
            end
        end
        else begin
            reg_pc <= 0;
            reg_pc_plus_cuatro <= 4;
            reg_instruction_fetch <= 0;
            o_dato <= 0;
            reg_contador_ciclos <= 0;
        end
    end

  end

endmodule
