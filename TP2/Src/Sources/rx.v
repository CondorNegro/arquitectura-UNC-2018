 `timescale 1ns / 1ps

// Constantes.
`define WIDTH_WORD             8              // Tamanio de palabra
`define CANT_BIT_STOP          2              // Cantidad de bit de parada


module rx(
    i_rate,
    i_bit_rx, 
    i_reset,
    o_rx_done,
    o_data_out
    );

// Parametros.
parameter WIDTH_WORD    = `WIDTH_WORD;
parameter CANT_BIT_STOP  = `CANT_BIT_STOP;

// Local Param
localparam ESPERA = 4'b0001;
localparam START = 4'b0010;
localparam READ = 4'b0100;
localparam STOP = 4'b1000;


// Entradas - Salidas.

input i_rate;  
input i_bit_rx;   
input i_reset; 
output reg o_rx_done; 
output reg [ WIDTH_WORD - 1 : 0 ] o_data_out;       



// Registros.
reg [ 3 : 0 ] reg_state;
reg [ 3 : 0 ] reg_next_state;
reg [ WIDTH_WORD - 1 : 0 ] reg_buffer;
reg [ 5 : 0] reg_contador_ticks;
reg [$clog2 (WIDTH_WORD) - 1 : 0] reg_contador_bits;
reg [$clog2 (CANT_BIT_STOP) - 1 : 0] reg_contador_bits_stop;


always@( posedge i_rate ) begin //Memory
     // Se resetean los registros.
    if (~ i_reset) begin
        reg_state <= 1;
        reg_next_state <= 1;
        reg_buffer <= 0;
        reg_contador_bits <= 0;
        reg_contador_ticks <= 0;
        reg_contador_bits_stop <= 0;
        o_data_out <= 0;
    end 

    else begin
        o_data_out <= o_data_out;
        reg_state <= reg_next_state;
        reg_contador_ticks <= reg_contador_ticks + 1;
        
        if (reg_state == READ) begin
            if ( ((reg_contador_ticks % 16) == 0) && (reg_contador_ticks != 0) ) begin
                reg_buffer[reg_contador_bits] <=  i_bit_rx;
                reg_contador_bits <= reg_contador_bits + 1;
                reg_contador_bits_stop <= 0;
            end
            else begin
                reg_buffer <= reg_buffer;
                reg_contador_bits <= reg_contador_bits;
                reg_contador_bits_stop <= reg_contador_bits_stop;
            end
        end

        else if ( reg_state == STOP ) begin
            if ( ((reg_contador_ticks % 16) == 0) && (reg_contador_ticks != 0) ) begin
                reg_contador_bits <= 0;
                reg_contador_bits_stop <= reg_contador_bits_stop + 1;
                reg_buffer <= reg_buffer;
            end
            else begin
                reg_contador_bits <= reg_contador_bits;
                reg_contador_bits_stop <= reg_contador_bits_stop;
                reg_buffer <= reg_buffer;
            end
        end

        else begin
            reg_buffer <= reg_buffer; 
            reg_contador_bits <= 0;
            reg_contador_bits_stop <= 0;
        end
        
    end
end


always@( * ) begin //NEXT - STATE logic
    
    case (reg_state)
        
        ESPERA : begin
            if (i_bit_rx == 0) begin
                reg_next_state = START;
                reg_contador_ticks = 0;
                reg_contador_bits =  reg_contador_bits;
                reg_contador_bits_stop = reg_contador_bits_stop;
            end
            else begin
                reg_next_state = ESPERA;
                reg_contador_ticks = reg_contador_ticks;
                reg_contador_bits =  reg_contador_bits;
                reg_contador_bits_stop = reg_contador_bits_stop;
            end  
        end
        
        START : begin
            if (reg_contador_ticks == 7) begin
                reg_next_state = READ;
                reg_contador_ticks = 0;
                reg_contador_bits =  reg_contador_bits;
                reg_contador_bits_stop = reg_contador_bits_stop;
            end
            else begin
                reg_next_state = START;
                reg_contador_ticks = reg_contador_ticks;
                reg_contador_bits =  reg_contador_bits;
                reg_contador_bits_stop = reg_contador_bits_stop;
            end  
        end
        
        READ : begin
            if (reg_contador_bits == WIDTH_WORD) begin
                reg_next_state = STOP;
                reg_contador_ticks = 0;
                reg_contador_bits = reg_contador_bits;
                reg_contador_bits_stop = reg_contador_bits_stop;
            end
            else begin
                reg_next_state = READ;
                reg_contador_ticks = reg_contador_ticks;
                reg_contador_bits = reg_contador_bits;
                reg_contador_bits_stop = reg_contador_bits_stop;
            end  
        end
        
        STOP : begin

            if (i_bit_rx == 1) begin
                if ( reg_contador_bits_stop == CANT_BIT_STOP) begin
                    reg_next_state = ESPERA;
                    reg_contador_bits = reg_contador_bits;
                    reg_contador_bits_stop = reg_contador_bits_stop;
                    reg_contador_ticks = reg_contador_ticks;
                end
                else begin
                    reg_next_state = STOP;
                    reg_contador_bits = reg_contador_bits;
                    reg_contador_ticks = reg_contador_ticks;
                    reg_contador_bits_stop = reg_contador_bits_stop;
                end  
            end

            else begin
                    reg_next_state = ESPERA;
                    reg_contador_bits = reg_contador_bits;
                    reg_contador_bits_stop = reg_contador_bits_stop;
                    reg_contador_ticks = reg_contador_ticks;
            end
            
        end
        
        default: begin
                reg_next_state = ESPERA;
                reg_contador_bits = reg_contador_bits;
                reg_contador_bits_stop = reg_contador_bits_stop;
                reg_contador_ticks = reg_contador_ticks;
            end
    
    endcase 
end


always@( * ) begin //Output logic
    
    case (reg_state)
        
        ESPERA : begin
            o_rx_done = 0;
            o_data_out = o_data_out;
        end
        
        START : begin
            o_rx_done = 0;
            o_data_out = 0;
        end
        
        READ : begin
            o_rx_done = 0;
            o_data_out = 0;
        end
        
        STOP : begin

            if ( reg_contador_bits_stop == CANT_BIT_STOP) begin
                o_rx_done = 1;
                o_data_out = reg_buffer;
            end
            else begin
                o_rx_done = 0;
                o_data_out = 0;
            end  
            
        end
        
        default : begin
                    o_rx_done = 0;
                    o_data_out = 0;
                end
    
    endcase 
end

endmodule


