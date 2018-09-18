 `timescale 1ns / 1ps

// Constantes.
`define WIDTH_WORD_TX             8              // Tamanio de palabra
`define CANT_BIT_STOP          2              // Cantidad de bit de parada


module tx(
    i_rate,
    i_data_in,
    i_reset,
    i_tx_start,
    o_bit_tx,
    o_tx_done
    );

// Parametros.
parameter WIDTH_WORD_TX    = `WIDTH_WORD_TX;
parameter CANT_BIT_STOP  = `CANT_BIT_STOP;

// Local Param
localparam ESPERA = 4'b0001;
localparam START = 4'b0010;
localparam READ = 4'b0100;
localparam STOP = 4'b1000;


// Entradas - Salidas.

input i_rate;
input [ WIDTH_WORD_TX - 1 : 0 ] i_data_in;       
input i_reset; 
input  i_tx_start;  
output reg o_bit_tx;  
output reg o_tx_done; 



// Registros.
reg [ 3 : 0 ] reg_state;
reg [ 3 : 0 ] reg_next_state;
reg [ 7 : 0] reg_contador_ticks;
reg [$clog2 (WIDTH_WORD_TX)  : 0] reg_contador_bits;
reg [$clog2 (CANT_BIT_STOP) : 0] reg_contador_bits_stop;




always@( posedge i_rate ) begin //Memory
     // Se resetean los registros.
    if (~ i_reset) begin
        reg_state <= 1;
        reg_next_state <= 1;
        reg_contador_bits <= 0;
        reg_contador_ticks <= 0;
        reg_contador_bits_stop <= 0;
    end 

    else begin
        reg_state <= reg_next_state;
        reg_contador_ticks <= reg_contador_ticks + 1;
        
        if (reg_state == READ) begin
            if (( (reg_contador_ticks % 16) == 0 ) && (reg_contador_ticks != 0)) begin
                reg_contador_bits <= reg_contador_bits + 1;
                reg_contador_bits_stop <= 0;
            end
            else begin
                reg_contador_bits <= reg_contador_bits;
                reg_contador_bits_stop <= reg_contador_bits_stop;
            end
        end

        else if ( reg_state == STOP ) begin
            if (( (reg_contador_ticks % 16) == 0 ) && (reg_contador_ticks != 0)) begin
                reg_contador_bits <= 0;
                reg_contador_bits_stop <= reg_contador_bits_stop + 1;  
            end
            else begin
                reg_contador_bits <= reg_contador_bits;
                reg_contador_bits_stop <= reg_contador_bits_stop;
               
            end
        end

        else begin
            reg_contador_bits <= 0;
            reg_contador_bits_stop <= 0;
        end
        
    end
end


always@( * ) begin //NEXT - STATE logic
    
    case (reg_state)
        
        ESPERA : begin
            if (i_tx_start == 1) begin
                reg_next_state = START;
                reg_contador_ticks = 0;
                reg_contador_bits =  0;
                reg_contador_bits_stop = 0;
            end
            else begin
                reg_next_state = ESPERA;
                reg_contador_ticks = 0;
                reg_contador_bits =  0;
                reg_contador_bits_stop = 0;
            end  
        end
        
        START : begin
            if (reg_contador_ticks == 16) begin
                reg_next_state = READ;
                reg_contador_ticks = reg_contador_ticks;
                reg_contador_bits =  0;
                reg_contador_bits_stop = 0;
            end
            else begin
                reg_next_state = START;
                reg_contador_ticks = reg_contador_ticks;
                reg_contador_bits =  0;
                reg_contador_bits_stop = 0;
            end  
        end
        
        READ : begin
            if (reg_contador_bits == WIDTH_WORD_TX) begin
                reg_next_state = STOP;
                reg_contador_ticks = 0;
                reg_contador_bits = 0;
                reg_contador_bits_stop = 0;
            end
            else begin
                reg_next_state = READ;
                reg_contador_ticks = reg_contador_ticks;
                reg_contador_bits = reg_contador_bits;
                reg_contador_bits_stop = 0;
            end  
        end
        
        STOP : begin
            if ( reg_contador_bits_stop == CANT_BIT_STOP ) begin
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
        
        default : begin
            reg_next_state = ESPERA;
            reg_contador_bits = reg_contador_bits;
            reg_contador_ticks = reg_contador_ticks;
            reg_contador_bits_stop = reg_contador_bits_stop;
        end
    
    endcase 
end


always@( * ) begin //Output logic
    
    case (reg_state)
        
        ESPERA : begin
            o_tx_done = 1;
            o_bit_tx = 1; 
        end
        
        START : begin
            o_tx_done = 0;
            o_bit_tx = 0;
        end
        
        READ : begin
            o_tx_done = 0;
            o_bit_tx = i_data_in [ (WIDTH_WORD_TX-1) - reg_contador_bits];
        end
        
        STOP : begin
            if ( reg_contador_bits_stop == CANT_BIT_STOP) begin
                o_tx_done = 1;
                o_bit_tx = 1;
            end
            else begin
                o_tx_done = 0;
                o_bit_tx = 1;
            end  
            
        end
        
        default : begin
                o_tx_done = 1;
                o_bit_tx = 1;
        end
    
    endcase 
end

endmodule
