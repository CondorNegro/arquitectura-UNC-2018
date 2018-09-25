 `timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 2. UART.
// Modulo rx.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////////////////////


// Constantes.
`define WIDTH_WORD                8          // Tamanio de palabra util enviada por trama UART.
`define CANT_BIT_STOP_RX          2          // Cantidad de bits de parada de trama UART.


module rx(
    i_clock,
    i_rate,
    i_bit_rx, 
    i_reset,
    o_rx_done,
    o_data_out
    );

// Parametros.
parameter WIDTH_WORD    = `WIDTH_WORD;
parameter CANT_BIT_STOP  = `CANT_BIT_STOP_RX;

// Local Param
localparam ESPERA = 5'b00001;
localparam START = 5'b00010;
localparam READ = 5'b00100;
localparam STOP = 5'b01000;
localparam ERROR = 5'b10000; // Estado en caso de error en bits de stop (llega un 1 como primer bit de stop y luego un 0).


// Entradas - Salidas.
input i_clock;
input i_rate;  
input i_bit_rx;   
input i_reset; 
output reg o_rx_done; 
output reg [ WIDTH_WORD - 1 : 0 ] o_data_out;       



// Registros.
reg [ 4 : 0 ] reg_state;
reg [ 4 : 0 ] reg_next_state;
reg [ WIDTH_WORD - 1 : 0 ] reg_buffer;
reg [ 5 : 0] reg_contador_ticks; // Debe contar como maximo hasta 32. (Por los dos bits de stop).
reg [$clog2 (WIDTH_WORD) : 0] reg_contador_bits;
reg [($clog2 (CANT_BIT_STOP)) : 0] reg_contador_bits_stop;


always@( posedge i_clock ) begin //Memory
     // Se resetean los registros.
    if (~ i_reset) begin
            reg_state <= 1;
            reg_buffer <= 0;
            reg_contador_bits <= 0;
            reg_contador_ticks <= 0;
            reg_contador_bits_stop <= 0;
    end
    else if (i_rate) begin 
                reg_state <= reg_next_state;                
                if (reg_state == READ) begin
                    // 16 ticks por bit transmitido.
                    if ( ((reg_contador_ticks % 15) == 0) && (reg_contador_ticks != 0) ) begin
                        reg_buffer[(WIDTH_WORD-1) - reg_contador_bits] <=  i_bit_rx;
                        reg_contador_bits <= reg_contador_bits + 1;
                        reg_contador_bits_stop <= 0;
                        reg_contador_ticks <= 0;
                    end
                    else begin
                        reg_buffer <= reg_buffer;
                        reg_contador_bits <= reg_contador_bits;
                        reg_contador_bits_stop <= reg_contador_bits_stop;
                        reg_contador_ticks <= reg_contador_ticks + 1;
                    end
                end

                else if ( reg_state == STOP ) begin
                    // 16 ticks por bit transmitido.
                    if ( ((reg_contador_ticks % 15) == 0) && (reg_contador_ticks != 0) ) begin
                        reg_contador_bits <= 0;
                        reg_contador_bits_stop <= reg_contador_bits_stop + 1;
                        reg_buffer <= reg_buffer;
                        reg_contador_ticks <= reg_contador_ticks + 1;
                    end
                    else begin
                        reg_contador_bits <= reg_contador_bits;
                        reg_contador_bits_stop <= reg_contador_bits_stop;
                        reg_buffer <= reg_buffer;
                        reg_contador_ticks <= reg_contador_ticks + 1;
                    end
                end
                
                else if ( (reg_state == ESPERA) ) begin
                    reg_contador_ticks <=  0;
                    reg_contador_bits <=  0;
               end
               
               else if ( (reg_state == START && reg_next_state == READ) ) begin
                   reg_contador_ticks <=  0;
                   reg_contador_bits <=  0;
                   reg_buffer <= 0;
              end

                else begin
                    reg_buffer <= reg_buffer; 
                    reg_contador_bits <= 0;
                    reg_contador_bits_stop <= 0;
                    reg_contador_ticks <=  reg_contador_ticks + 1;
                end
                
            
    end
    else begin
        reg_state <= reg_state;
        reg_buffer <= reg_buffer;
        reg_contador_bits <= reg_contador_bits;
        reg_contador_ticks <= reg_contador_ticks;
        reg_contador_bits_stop <= reg_contador_bits_stop;
    end 
    
end


always@( * ) begin //NEXT - STATE logic
    
    case (reg_state)
        
        ESPERA : begin
            if (i_bit_rx == 0) begin
                reg_next_state = START;
            end
            else begin
                reg_next_state = ESPERA;
            end  
        end
        
        START : begin
            if (reg_contador_ticks == 8) begin
                reg_next_state = READ;
            end
            else begin
                reg_next_state = START;
            end  
        end
        
        READ : begin
            if (reg_contador_bits == WIDTH_WORD) begin
                reg_next_state = STOP;
            end
            else begin
                reg_next_state = READ;
            end  
        end
        
        STOP : begin
            if (reg_contador_ticks > 16) begin // Salí de los bits de datos.
                if (i_bit_rx == 1) begin
                    if ( reg_contador_bits_stop == CANT_BIT_STOP ) begin
                        reg_next_state = ESPERA;

                    end
                    else begin
                        reg_next_state = STOP;
                    end  
                end

                else begin
                        if ( reg_contador_ticks < 24) begin // Menos de la mitad del segundo bit de stop y es cero.
                            reg_next_state = ERROR; // Faltan 8 ticks para terminar de recorrer el bit de stop erróneo.
                        end 
                        else begin
                            reg_next_state = ESPERA;
                        end
                        
                end
            end
            else begin
                    reg_next_state = STOP;
            end
            
        end
        
        ERROR : begin
            // Para salir del error se deben contar 8 ticks porque estoy a la mitad de un bit recibido.
            if (reg_contador_ticks == 8) begin
                reg_next_state = ESPERA;
            end
            else begin
                reg_next_state = ERROR;
            end  
        end



        default: begin
                reg_next_state = ESPERA;
            end
    
    endcase 
end


always@( * ) begin //Output logic
    
    case (reg_state)
        
        ESPERA : begin
            o_rx_done = 0;
            o_data_out = reg_buffer;
        end
        
        START : begin
            o_rx_done = 0;
            o_data_out = reg_buffer;
        end
        
        READ : begin
            o_rx_done = 0;
            o_data_out = reg_buffer;
        end
        
        STOP : begin

            if ( reg_contador_bits_stop == CANT_BIT_STOP) begin
                o_rx_done = 1;
                o_data_out = reg_buffer;
            end
            else begin
                o_rx_done = 0;
                o_data_out = reg_buffer;
            end  
            
        end

        ERROR : begin
            o_rx_done = 0;
            o_data_out = reg_buffer;
        end
        
        default : begin
            o_rx_done = 0;
            o_data_out = reg_buffer;
        end
    
    endcase 
end

endmodule


