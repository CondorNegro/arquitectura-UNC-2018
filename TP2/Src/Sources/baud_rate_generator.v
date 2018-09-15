 `timescale 1ns / 1ps

// Constantes.
`define BAUD_RATE           9600        // Baud rate a generar.
`define FREC_CLOCK_MHZ      100.0       // Frecuencia del clock en MHZ.

module baud_rate_generator(
    i_clock, 
    i_reset,
    o_rate
    );

// Parametros.
parameter BAUD_RATE    = `BAUD_RATE;
parameter FREC_CLOCK_MHZ  = `FREC_CLOCK_MHZ;

// Local Param
localparam integer MODULO_CONTADOR = (FREC_CLOCK_MHZ * 1000000) / (BAUD_RATE * 16);


// Entradas - Salidas.

input i_clock;     
input i_reset; 
output reg o_rate;       



// Registros.
reg [ $clog2 (MODULO_CONTADOR) - 1 : 0 ] reg_contador;


always@( posedge i_clock) begin
     // Se resetean los registros.
    if (~ i_reset) begin
        reg_contador <= 0;
    end 

    else begin
        if (reg_contador < MODULO_CONTADOR) begin
            o_rate <= 0;
            reg_contador <= reg_contador+1;
        end
        else begin
            o_rate <= 1;
            reg_contador <= 0;
        end
    end
end

endmodule


