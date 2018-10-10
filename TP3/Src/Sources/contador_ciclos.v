 `timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 3. BIP I.
// Contador de ciclos.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////////////////////


module contador_ciclos
    #(
        parameter CONTADOR_LENGTH = 11
    )
    (
        input i_clock, 
        input i_reset,
        output reg [CONTADOR_LENGTH - 1 : 0] o_cuenta
    );



always@( posedge i_clock) begin
     // Se resetean los registros.
    if (~ i_reset) begin
        o_cuenta <= 0;
    end 
    else begin
        o_cuenta <= o_cuenta + 1;
    end
end

endmodule


