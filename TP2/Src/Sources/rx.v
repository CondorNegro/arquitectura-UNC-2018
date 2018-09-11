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


always@( posedge i_rate ) begin //Memory
     // Se resetean los registros.
    if (~ i_reset) begin
        reg_state <= 0;
        reg_next_state <= 0;
        reg_buffer <= 0;
    end 

    else begin
        reg_state <= reg_next_state;
    end
end


always@( * ) begin //NEXT - STATE logic
    
    case (reg_state)
        
        ESPERA : begin
            if () begin
                reg_next_state = START;
            end
            else begin
                reg_next_state = ESPERA;
            end  
        end
        
        START : begin
            if () begin
                reg_next_state = READ;
            end
            else begin
                reg_next_state = START;
            end  
        end
        
        READ : begin
            if () begin
                reg_next_state = STOP;
            end
            else begin
                reg_next_state = READ;
            end  
        end
        
        STOP : begin
            if () begin
                reg_next_state = ESPERA;
            end
            else begin
                reg_next_state = STOP;
            end  
        end
        
        default : reg_next_state = ESPERA;
    
    endcase 
end


always@( * ) begin //Output logic
    
    case (reg_state)
        
        ESPERA : begin
            o_rx_done = 0;
            o_data_out = 0;
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
            o_rx_done = 1;
            o_data_out = reg_buffer; 
        end
        
        default : begin
                    o_rx_done = 0;
                    o_data_out = 0;
                end
    
    endcase 
end

endmodule


