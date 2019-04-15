`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Debug_unit.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////////////////////


module debug_unit
#(
  parameter OUTPUT_WORD_LENGTH = 8,    //  Cantidad de bits de la palabra a transmitir.
  parameter HALT_INSTRUCTION = 32'hFFFFFFFF, //  Opcode de la instruccion HALT.
  parameter ADDR_MEM_PROG_LENGTH = 10,      //  Cantidad de bits del bus de direcciones de la memoria de programa.
  parameter ADDR_MEM_DATOS_LENGTH = 10,     //  Cantidad de bits del bus de direcciones de la memoria de datos.
  parameter CANTIDAD_ESTADOS = 13,      //  Cantidad de estados
  parameter LONGITUD_INSTRUCCION = 32,  //  Cantidad de bits de la instruccion
  parameter CANT_BITS_REGISTRO = 32,
  parameter CANT_COLUMNAS_MEM_DATOS = 4,
  parameter CANT_DATOS_DATABASE = 12, // Cantidad de datos a traer del database
  parameter CANT_REGISTROS = 32,
  parameter RAM_DATOS_DEPTH = 1024

)
(
    input i_clock,
    input i_reset,
    input i_tx_done,
    input i_rx_done,
    input [OUTPUT_WORD_LENGTH - 1 : 0] i_data_rx,
    input i_soft_reset_ack,
    input i_flag_halt,
    input [CANT_BITS_REGISTRO - 1 : 0] i_dato_database,
    input [CANT_BITS_REGISTRO - 1 : 0] i_dato_mem_datos,
    input i_bit_sucio,
    input [CANT_BITS_REGISTRO - 1 : 0] i_reg_data_from_register_file,
    output reg [clogb2 (CANT_REGISTROS - 1) - 1 : 0] o_reg_read_to_register_file,
    output reg o_tx_start,
    output reg [OUTPUT_WORD_LENGTH - 1 : 0] o_data_tx,
    output reg o_soft_reset,
    output reg o_write_mem_programa,
    output reg [ADDR_MEM_PROG_LENGTH - 1 : 0] o_addr_mem_programa,
    output reg [LONGITUD_INSTRUCCION - 1 : 0] o_dato_mem_programa,
    output reg o_modo_ejecucion,
    output reg o_enable_mem_programa,
    output reg o_rsta_mem,
    output reg o_regcea_mem,
    output reg o_enable_PC,
    output reg o_control_mux_addr_mem_top_if,
    output reg [clogb2 (CANT_DATOS_DATABASE - 1) - 1 : 0] o_control_database,
    output reg o_enable_pipeline,

    output reg o_control_write_read_mem_datos,
    output reg o_control_address_mem_datos,
    output reg o_enable_mem_datos,
    output [ADDR_MEM_DATOS_LENGTH + clogb2 (CANT_COLUMNAS_MEM_DATOS - 1) - 1 : 0] o_address_debug_unit,
    
    output reg o_led
 );

// Funcion para calcular el logaritmo en base 2.
function integer clogb2;
  input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
          depth = depth >> 1;
endfunction


localparam CANT_BITS_CONTROL_DATABASE = clogb2 (CANT_DATOS_DATABASE - 1);
localparam CANT_BITS_CONTADOR_DATOS = clogb2 (LONGITUD_INSTRUCCION / OUTPUT_WORD_LENGTH - 1);

// Estados
localparam ESPERA                       = 13'b0000000000001;
localparam SOFT_RESET                   = 13'b0000000000010;    
localparam ESPERA_PC_ACK                = 13'b0000000000100;
localparam READ_PROGRAMA                = 13'b0000000001000;
localparam ESPERA_START                 = 13'b0000000010000;
localparam EJECUCION                    = 13'b0000000100000;
localparam SEND_PART3                   = 13'b0000001000000;
localparam SEND_PART2                   = 13'b0000010000000;
localparam SEND_PART1                   = 13'b0000100000000;
localparam SEND_PART0                   = 13'b0001000000000;
localparam REGISTROS_DATA_CHECK         = 13'b0010000000000;
localparam MEM_DATOS_CHECK              = 13'b0100000000000;
localparam ESPERA_MEM_DATOS_CHECK_ACK   = 13'b1000000000000;




//localparam CANT_BITS_DEPTH_MEM = 2 ** ADDR_MEM_PROG_LENGTH;

// Registros.
reg [ CANTIDAD_ESTADOS - 1 : 0 ] reg_state;
reg [ CANTIDAD_ESTADOS - 1 : 0 ] reg_next_state;
reg registro_rx_done;
reg [LONGITUD_INSTRUCCION - 1 : 0] reg_instruccion;
reg [CANT_BITS_CONTADOR_DATOS - 1 : 0] reg_contador_datos;
reg [ADDR_MEM_PROG_LENGTH - 1 : 0] reg_contador_addr_mem;
reg [LONGITUD_INSTRUCCION - 1 : 0] o_next_dato_mem_programa;
reg reg_next_modo_ejecucion;
reg [CANT_BITS_CONTROL_DATABASE - 1 : 0] reg_contador_datos_database;
reg [clogb2 (CANT_REGISTROS - 1) - 1 : 0] reg_contador_send_registros;

//reg [OUTPUT_WORD_LENGTH - 1 : 0] o_data_tx_next;

reg flag_send_mem; //Sirve para que el primer dato que se envia sea la instruccion valida y no un 1 (reg instruccion inicializa en 1)


reg flag_enable_pc; //Flag para habilitar o no el enable_pc.
reg flag_enable_pipeline; //Flag para habilitar o no el enable_pipeline.


reg [ADDR_MEM_DATOS_LENGTH - 1 : 0] reg_contador_address_mem_datos;
reg [1 : 0] reg_contador_send_datos_mem_datos;

assign o_address_debug_unit = reg_contador_address_mem_datos;


always @ ( posedge i_clock ) begin //Memory
  // Se resetean los registros.
  
    if (~ i_reset) begin
        reg_state <= 1;
        registro_rx_done <= 0;
        reg_instruccion <= 1;
        reg_contador_datos <= 0;
        reg_contador_addr_mem <= 0;
        o_dato_mem_programa <= HALT_INSTRUCTION;
        flag_send_mem<=0;
        o_modo_ejecucion <= 0; // Continuo.
        flag_enable_pc <= 1'b0;
        reg_contador_datos_database <= 0;
        reg_contador_address_mem_datos <= 0;
        reg_contador_send_datos_mem_datos <= 0;
        reg_contador_send_registros <= 0;
    end

    else begin
        reg_state <= reg_next_state;
        registro_rx_done <= i_rx_done;
        o_dato_mem_programa <= o_next_dato_mem_programa;
        o_modo_ejecucion <= reg_next_modo_ejecucion;
        if (reg_state == READ_PROGRAMA) begin
        if (~i_rx_done & registro_rx_done) begin
            
            reg_instruccion <= reg_instruccion << OUTPUT_WORD_LENGTH;
            reg_instruccion [ OUTPUT_WORD_LENGTH - 1 : 0] <= i_data_rx;
            reg_contador_datos <= reg_contador_datos + 1;
            if ((reg_contador_datos ==  0) && (flag_send_mem == 1)) begin
            reg_contador_addr_mem <= reg_contador_addr_mem + 1;
            
            end
            else begin
            reg_contador_addr_mem <= reg_contador_addr_mem;
            flag_send_mem<=1;
            end
        end
        else begin
            reg_instruccion  <= reg_instruccion;
            reg_contador_datos <= reg_contador_datos;
            reg_contador_addr_mem <= reg_contador_addr_mem;
        end
        end
        else begin
        flag_send_mem <= 0;
        reg_instruccion <= 1;
        reg_contador_datos <= 0;
        reg_contador_addr_mem <= 0;
        end
        
        
        if ((reg_state == EJECUCION) && (reg_next_modo_ejecucion == 1'b1)) begin //Modo debug en EJECUCION.
            flag_enable_pc <= 1'b1;
        end
        else if ( (i_flag_halt) && (reg_next_modo_ejecucion == 1'b0)) begin //Modo continuo con HALT.
            flag_enable_pc <= 1'b1;
        end
        else begin
            flag_enable_pc <= 1'b0;
        end
        
        
        if (reg_state == SEND_PART0 && reg_next_state == SEND_PART3) begin
        reg_contador_datos_database <= reg_contador_datos_database + 1;
        end
        else if (reg_state == EJECUCION) begin
            reg_contador_datos_database <= 0;
        end
        else begin
        reg_contador_datos_database <= reg_contador_datos_database;
        end

        if (reg_state == MEM_DATOS_CHECK) begin
            if ((i_bit_sucio | (reg_contador_address_mem_datos == (RAM_DATOS_DEPTH - 1))) && reg_contador_send_datos_mem_datos <= 2) begin
                reg_contador_send_datos_mem_datos <= reg_contador_send_datos_mem_datos + 1;
            end
            else begin
               reg_contador_send_datos_mem_datos <= 0;
            end
            if ((reg_contador_address_mem_datos == (RAM_DATOS_DEPTH - 1)) | (reg_contador_send_datos_mem_datos > 0)) begin
                reg_contador_address_mem_datos <= reg_contador_address_mem_datos;
            end
            else begin
                reg_contador_address_mem_datos <= reg_contador_address_mem_datos + 1;
            end
            
            
        end
        else if ((reg_state == ESPERA_START) || (reg_state == ESPERA)) begin
            reg_contador_address_mem_datos <= 0;
            reg_contador_send_datos_mem_datos <= 0;
        end
        else begin
            reg_contador_address_mem_datos <= reg_contador_address_mem_datos;
            reg_contador_send_datos_mem_datos <= reg_contador_send_datos_mem_datos;
        end

        if (reg_state == REGISTROS_DATA_CHECK) begin
            if (reg_contador_send_registros <= (clogb2 (CANT_BITS_REGISTRO - 1) - 1)) begin
                reg_contador_send_registros <= reg_contador_send_registros + 1;
            end
            else begin
                reg_contador_send_registros <= reg_contador_send_registros;
            end
        end
        else if ((reg_state == ESPERA_START) || (reg_state == ESPERA)) begin
            reg_contador_send_registros <= 0;
        end
        else begin
            reg_contador_send_registros <= reg_contador_send_registros;
        end

    end

end

// Always para que no se desensincronicen los flancos del clock en modo debug.
always@ ( negedge i_clock ) begin
    if (~ i_reset) begin
      flag_enable_pipeline <= 1'b0;
    end
    else begin
        if (reg_state == EJECUCION) begin
              flag_enable_pipeline <= 1'b1; //Habilito pipelines.
        end
        else begin
              flag_enable_pipeline <= 1'b0;
        end
    end
end



always@( * ) begin //NEXT - STATE logic

 case (reg_state)

       ESPERA : begin
            if ((~i_rx_done & registro_rx_done) && (i_data_rx == 8'b00000000)) begin
                reg_next_state = SOFT_RESET;
            end
            else begin
                reg_next_state = ESPERA;
            end
       end

       SOFT_RESET : begin
            if (i_soft_reset_ack == 1'b0) begin
                reg_next_state = ESPERA_PC_ACK;
            end
            else begin
                reg_next_state = SOFT_RESET;
            end
       end

       ESPERA_PC_ACK : begin
            if ((~i_rx_done & registro_rx_done) && (i_data_rx == 8'b00000001)) begin
                reg_next_state = READ_PROGRAMA;
            end
            else begin
                reg_next_state = ESPERA_PC_ACK;
            end
       end

       READ_PROGRAMA : begin
            if ((reg_instruccion == HALT_INSTRUCTION) && (flag_send_mem == 1) && (reg_contador_datos ==  0) ) begin
                reg_next_state = ESPERA_START;
            end
            else begin
                reg_next_state = READ_PROGRAMA;
            end
       end
       ESPERA_START : begin
            if ((~i_rx_done & registro_rx_done) && ((i_data_rx == 8'b00000011) || (i_data_rx == 8'b00000111))) begin
                reg_next_state = EJECUCION;
            end
            else begin
                reg_next_state = ESPERA_START;
            end
       end

        EJECUCION : begin
            if ( (i_flag_halt) && reg_next_modo_ejecucion == 1'b0) begin //Modo continuo con HALT.
                reg_next_state = SEND_PART3;
            end
            else if (reg_next_modo_ejecucion == 1'b1) begin // Modo Debug
                if (flag_enable_pc == 1'b1) begin
                    reg_next_state = SEND_PART3;
                end
                else begin
                    reg_next_state = EJECUCION;
                end
            end
            else begin
                reg_next_state = EJECUCION;
            end
       end
       
       


        SEND_PART3  : begin
            if ((~i_rx_done & registro_rx_done) && (i_data_rx == 8'b00001000)) begin 
                reg_next_state = SEND_PART2;
            end
            else begin
                reg_next_state = SEND_PART3;
            end
        end

        SEND_PART2  : begin
            if ((~i_rx_done & registro_rx_done) && (i_data_rx == 8'b00010000)) begin 
                reg_next_state = SEND_PART1;
            end
            else begin
                reg_next_state = SEND_PART2;
            end
       end


       SEND_PART1  : begin
            if ((~i_rx_done & registro_rx_done) && (i_data_rx == 8'b00011000)) begin 
                reg_next_state = SEND_PART0;
            end
            else begin
                reg_next_state = SEND_PART1;
            end
       end


       SEND_PART0  : begin
            if ((~i_rx_done & registro_rx_done) && (i_data_rx == 8'b00100000)) begin
                if (reg_contador_datos_database != (CANT_DATOS_DATABASE - 1)) begin
                    reg_next_state = SEND_PART3;
                end
                else if (reg_contador_send_registros < (CANT_REGISTROS - 1)) begin // Se enviaron todos los datos de los latches.
                    reg_next_state = REGISTROS_DATA_CHECK;
                end
                else begin
                    reg_next_state = MEM_DATOS_CHECK;
                end
            end
            else begin
                reg_next_state = SEND_PART0;
            end     
       end

       
        REGISTROS_DATA_CHECK : begin
            reg_next_state = SEND_PART3;
        end

       MEM_DATOS_CHECK : begin
            if ((reg_contador_address_mem_datos == (RAM_DATOS_DEPTH - 1)) && (reg_contador_send_datos_mem_datos == 2)) begin
                reg_next_state = ESPERA_MEM_DATOS_CHECK_ACK;             
            end
            else if (reg_contador_address_mem_datos == (RAM_DATOS_DEPTH - 1)) begin 
                reg_next_state = SEND_PART3;
            end
            else if (~i_bit_sucio && (reg_contador_address_mem_datos < (RAM_DATOS_DEPTH - 1))) begin
                reg_next_state = MEM_DATOS_CHECK;
            end
            else begin
                reg_next_state = SEND_PART3; 
            end
            
       end

       ESPERA_MEM_DATOS_CHECK_ACK : begin
            if ((~i_rx_done & registro_rx_done) && (i_data_rx == 8'b00101000)) begin
                if (reg_next_modo_ejecucion == 1'b0) begin // Modo continuo.
                    reg_next_state = ESPERA;
                end
                else if (i_flag_halt) begin // Modo debug con HALT
                    reg_next_state = ESPERA;
                end
                else begin // Modo debug sin HALT
                    reg_next_state = ESPERA_START;
                end
            end
            else begin
                reg_next_state = ESPERA_MEM_DATOS_CHECK_ACK;
            end
       end
      

       default begin
           reg_next_state = ESPERA;
       end
 endcase
end


always @ ( * ) begin //Output logic
 case (reg_state)

        ESPERA : begin
            o_tx_start = 0;
            o_data_tx = 0;
            o_soft_reset = 1; //Logica por nivel bajo.
            o_write_mem_programa = 0; //Write es en 1.
            o_addr_mem_programa = 0;
            o_next_dato_mem_programa = 0;
            reg_next_modo_ejecucion = 0; // Continuo.
            o_enable_mem_programa = 0;
            o_rsta_mem = 1;
            o_regcea_mem = 1;
            o_led = 1;
            o_enable_PC = 0;
            o_enable_pipeline = 0;
            o_control_mux_addr_mem_top_if = 1;
            o_control_database = 0;
            o_control_write_read_mem_datos = 0;
            o_control_address_mem_datos = 0;
            o_enable_mem_datos = 0;
            o_reg_read_to_register_file = 0;
        end

        SOFT_RESET : begin
            o_tx_start = 0;
            o_data_tx = 0;
            o_soft_reset = 0; //Logica por nivel bajo.
            o_write_mem_programa = 0; //Write es en 1.
            o_addr_mem_programa = 0;
            o_next_dato_mem_programa = 0;
            reg_next_modo_ejecucion = 0; // Continuo.
            o_enable_mem_programa = 1;
            o_rsta_mem = 0;
            o_regcea_mem = 0;
            o_led = 0;
            o_enable_PC = 0;
            o_enable_pipeline = 0;
            o_control_mux_addr_mem_top_if = 1;
            o_control_database = 0;
            o_control_write_read_mem_datos = 0;
            o_control_address_mem_datos = 0;
            o_enable_mem_datos = 0;
            o_reg_read_to_register_file = 0;
        end

        ESPERA_PC_ACK : begin
            o_tx_start = 1;
            o_data_tx = 8'b00000001;
            o_soft_reset = 1; //Logica por nivel bajo.
            o_write_mem_programa = 0; //Write es en 1.
            o_addr_mem_programa = 0;
            o_next_dato_mem_programa = HALT_INSTRUCTION;
            reg_next_modo_ejecucion = 0; // Continuo.
            o_enable_mem_programa = 1;
            o_rsta_mem = 0;
            o_regcea_mem = 0;
            o_led = 0;
            o_enable_PC = 0;
            o_enable_pipeline = 0;
            o_control_mux_addr_mem_top_if = 1; 
            o_control_database = 0;
            o_control_write_read_mem_datos = 0;
            o_control_address_mem_datos = 0;
            o_enable_mem_datos = 0;
            o_reg_read_to_register_file = 0;
        end

//{ CANT_BITS_CONTADOR_DATOS {1'b1} }
        READ_PROGRAMA : begin
            o_tx_start = 0;
            o_data_tx = 0;
            o_soft_reset = 1; //Logica por nivel bajo.
            if (reg_instruccion != HALT_INSTRUCTION && reg_contador_datos==0) begin // Para solucionar problema de instr. anterior a HALT.
                o_write_mem_programa = 1; //Write es en 1.
            end
            else begin
                o_write_mem_programa = 0; //Write es en 0.
            end
            o_addr_mem_programa = reg_contador_addr_mem;
            if (reg_contador_datos ==  0 && flag_send_mem==1) begin
            o_next_dato_mem_programa = reg_instruccion;
            end
            else begin
            o_next_dato_mem_programa = o_dato_mem_programa;
            end
            reg_next_modo_ejecucion = 0; // Continuo.
            o_enable_mem_programa = 1;
            o_rsta_mem = 0;
            o_regcea_mem = 0; 
            o_led = 0;
            o_enable_PC = 0;
            o_enable_pipeline = 0;
            o_control_mux_addr_mem_top_if = 1;
            o_control_database = 0;
            o_control_write_read_mem_datos = 0;
            o_control_address_mem_datos = 0;
            o_enable_mem_datos = 0;
            o_reg_read_to_register_file = 0;
        end

        ESPERA_START : begin
            o_tx_start = 0;
            o_data_tx = 0;
            o_soft_reset = 1; //Logica por nivel bajo.
            o_write_mem_programa = 0; //Write es en 1.
            o_addr_mem_programa = 0;
            o_next_dato_mem_programa = HALT_INSTRUCTION;
            reg_next_modo_ejecucion = i_data_rx [2];// Continuo en cero, paso a paso en 1.
            o_enable_mem_programa = 0;
            o_rsta_mem = 0;
            o_regcea_mem = 0;
            o_led = 0;
            o_enable_PC = 0;
            o_enable_pipeline = 0;
            o_control_mux_addr_mem_top_if = 0;
            o_control_database = 0;
            o_control_write_read_mem_datos = 0;
            o_control_address_mem_datos = 0;
            o_enable_mem_datos = 0;
            o_reg_read_to_register_file = 0;
       end

        EJECUCION : begin
            o_tx_start = 0;
            o_data_tx = 0;
            o_soft_reset = 1; //Logica por nivel bajo.
            o_write_mem_programa = 0; //Write es en 1.
            o_addr_mem_programa = 0;
            o_next_dato_mem_programa = 0;
            reg_next_modo_ejecucion = o_modo_ejecucion;// Continuo en cero, paso a paso en 1.
            
            o_rsta_mem = 0;
            o_regcea_mem = 0;
            o_led = 0;
            o_enable_pipeline = 1; 
            if (flag_enable_pc == 1'b1) begin
                o_enable_PC = 0; // Deshabilito el enable pc.
                o_enable_mem_programa = 0; // Deshabilito memoria de programa.
                o_enable_mem_datos = 0;
            end
            else begin
                o_enable_PC = 1;
                o_enable_mem_programa = 1;
                o_enable_mem_datos = 1;
            end
            if (flag_enable_pipeline == 1'b1) begin
                o_enable_pipeline = 1;
            end
            else begin
                o_enable_pipeline = 0;
            end
            o_control_mux_addr_mem_top_if = 0;
            o_control_database = 1;
            o_control_write_read_mem_datos = 0;
            o_control_address_mem_datos = 0;
            o_reg_read_to_register_file = 0;         
       end


       

        SEND_PART3 : begin 
            o_tx_start = 1;
            if ((reg_contador_send_datos_mem_datos == 0) && (reg_contador_send_registros == 0)) begin
                o_data_tx = (i_dato_database >> 24);
                o_control_database = reg_contador_datos_database + 2;
                o_control_write_read_mem_datos = 0;
                o_control_address_mem_datos = 0;
                o_enable_mem_datos = 0;
            end
            else if ((reg_contador_send_datos_mem_datos == 0) && (reg_contador_send_registros > 0)) begin
                o_data_tx = (i_reg_data_from_register_file >> 24);
                o_control_database = 0;
                o_control_write_read_mem_datos = 0;
                o_control_address_mem_datos = 0;
                o_enable_mem_datos = 0;
            end
            else if (reg_contador_send_datos_mem_datos == 1) begin 
                o_data_tx = i_dato_mem_datos >> 24;
                o_control_database = 0;
                o_control_write_read_mem_datos = 1;
                o_control_address_mem_datos = 1;
                o_enable_mem_datos = 0;
            end
            else begin
                o_data_tx = reg_contador_address_mem_datos >> 24;
                o_control_database = 0;
                o_control_write_read_mem_datos = 0;
                o_control_address_mem_datos = 0;
                o_enable_mem_datos = 0;
            end
            o_soft_reset = 1; //Logica por nivel bajo.
            o_write_mem_programa = 0; //Write es en 1.
            o_addr_mem_programa = 0;
            o_next_dato_mem_programa = 0;
            reg_next_modo_ejecucion = o_modo_ejecucion;// Continuo en cero, paso a paso en 1.
            o_enable_mem_programa = 0;
            o_rsta_mem = 0;
            o_regcea_mem = 0;
            o_led = 0;
            o_enable_PC = 0;
            o_enable_pipeline = 0;
            o_control_mux_addr_mem_top_if = 0;
            o_reg_read_to_register_file = reg_contador_send_registros;        
        end



        SEND_PART2 : begin 
            o_tx_start = 1;
            if ((reg_contador_send_datos_mem_datos == 0) && (reg_contador_send_registros == 0)) begin
                o_data_tx = (i_dato_database >> 16);
                o_control_database = reg_contador_datos_database + 2;
                o_control_write_read_mem_datos = 0;
                o_control_address_mem_datos = 0;
                o_enable_mem_datos = 0;
            end
            else if ((reg_contador_send_datos_mem_datos == 0) && (reg_contador_send_registros > 0)) begin
                o_data_tx = (i_reg_data_from_register_file >> 16);
                o_control_database = 0;
                o_control_write_read_mem_datos = 0;
                o_control_address_mem_datos = 0;
                o_enable_mem_datos = 0;
            end
            else if (reg_contador_send_datos_mem_datos == 1) begin 
                o_data_tx = i_dato_mem_datos >> 16;
                o_control_database = 0;
                o_control_write_read_mem_datos = 1;
                o_control_address_mem_datos = 1;
                o_enable_mem_datos = 0;
            end
            else begin
                o_data_tx = reg_contador_address_mem_datos >> 16;
                o_control_database = 0;
                o_control_write_read_mem_datos = 0;
                o_control_address_mem_datos = 0;
                o_enable_mem_datos = 0;
            end
            o_soft_reset = 1; //Logica por nivel bajo.
            o_write_mem_programa = 0; //Write es en 1.
            o_addr_mem_programa = 0;
            o_next_dato_mem_programa = 0;
            reg_next_modo_ejecucion = o_modo_ejecucion;// Continuo en cero, paso a paso en 1.
            o_enable_mem_programa = 0;
            o_rsta_mem = 0;
            o_regcea_mem = 0;
            o_led = 0;
            o_enable_PC = 0;
            o_enable_pipeline = 0;
            o_control_mux_addr_mem_top_if = 0;
            o_reg_read_to_register_file = reg_contador_send_registros;         
        end


        SEND_PART1 : begin 
            o_tx_start = 1;
            if ((reg_contador_send_datos_mem_datos == 0) && (reg_contador_send_registros == 0)) begin
                o_data_tx = (i_dato_database >> 8);
                o_control_database = reg_contador_datos_database + 2;
                o_control_write_read_mem_datos = 0;
                o_control_address_mem_datos = 0;
                o_enable_mem_datos = 0;
            end
            else if ((reg_contador_send_datos_mem_datos == 0) && (reg_contador_send_registros > 0)) begin
                o_data_tx = (i_reg_data_from_register_file >> 8);
                o_control_database = 0;
                o_control_write_read_mem_datos = 0;
                o_control_address_mem_datos = 0;
                o_enable_mem_datos = 0;
            end
            else if (reg_contador_send_datos_mem_datos == 1) begin 
                o_data_tx = i_dato_mem_datos >> 8;
                o_control_database = 0;
                o_control_write_read_mem_datos = 1;
                o_control_address_mem_datos = 1;
                o_enable_mem_datos = 0;
            end
            else begin
                o_data_tx = reg_contador_address_mem_datos >> 8;
                o_control_database = 0;
                o_control_write_read_mem_datos = 0;
                o_control_address_mem_datos = 0;
                o_enable_mem_datos = 0;
            end
            o_soft_reset = 1; //Logica por nivel bajo.
            o_write_mem_programa = 0; //Write es en 1.
            o_addr_mem_programa = 0;
            o_next_dato_mem_programa = 0;
            reg_next_modo_ejecucion = o_modo_ejecucion;// Continuo en cero, paso a paso en 1.
            o_enable_mem_programa = 0;
            o_rsta_mem = 0;
            o_regcea_mem = 0;
            o_led = 0;
            o_enable_PC = 0;
            o_enable_pipeline = 0;
            o_control_mux_addr_mem_top_if = 0;
            o_reg_read_to_register_file = reg_contador_send_registros;  
       end

        SEND_PART0 : begin 
            o_tx_start = 1;
            if ((reg_contador_send_datos_mem_datos == 0) && (reg_contador_send_registros == 0)) begin
                o_data_tx = (i_dato_database);
                o_control_database = reg_contador_datos_database + 2;
                o_control_write_read_mem_datos = 0;
                o_control_address_mem_datos = 0;
                o_enable_mem_datos = 0;
            end
            else if ((reg_contador_send_datos_mem_datos == 0) && (reg_contador_send_registros > 0)) begin
                o_data_tx = (i_reg_data_from_register_file);
                o_control_database = 0;
                o_control_write_read_mem_datos = 0;
                o_control_address_mem_datos = 0;
                o_enable_mem_datos = 0;
            end
            else if (reg_contador_send_datos_mem_datos == 1) begin 
                o_data_tx = i_dato_mem_datos;
                o_control_database = 0;
                o_control_write_read_mem_datos = 1;
                o_control_address_mem_datos = 1;
                o_enable_mem_datos = 0;
            end
            else begin
                o_data_tx = reg_contador_address_mem_datos;
                o_control_database = 0;
                o_control_write_read_mem_datos = 0;
                o_control_address_mem_datos = 0;
                o_enable_mem_datos = 0;
            end
            o_soft_reset = 1; //Logica por nivel bajo.
            o_write_mem_programa = 0; //Write es en 1.
            o_addr_mem_programa = 0;
            o_next_dato_mem_programa = 0;
            reg_next_modo_ejecucion = o_modo_ejecucion;// Continuo en cero, paso a paso en 1.
            o_enable_mem_programa = 0;
            o_rsta_mem = 0;
            o_regcea_mem = 0;
            o_led = 0;
            o_enable_PC = 0;
            o_enable_pipeline = 0;
            o_control_mux_addr_mem_top_if = 0;
            o_reg_read_to_register_file = reg_contador_send_registros;          
       end

       REGISTROS_DATA_CHECK : begin
            o_tx_start = 0;
            o_control_database = 0;
            o_data_tx = i_reg_data_from_register_file;
            o_soft_reset = 1; //Logica por nivel bajo.
            o_write_mem_programa = 0; //Write es en 1.
            o_addr_mem_programa = 0;
            o_next_dato_mem_programa = 0;
            reg_next_modo_ejecucion = o_modo_ejecucion;// Continuo en cero, paso a paso en 1.
            o_enable_mem_programa = 0;
            o_rsta_mem = 0;
            o_regcea_mem = 0;
            o_led = 0;
            o_enable_PC = 0;
            o_enable_pipeline = 0;
            o_control_mux_addr_mem_top_if = 0;
            
            o_control_write_read_mem_datos = 1;
            o_control_address_mem_datos = 1;
            o_enable_mem_datos = 0;
            o_reg_read_to_register_file = reg_contador_send_registros;  
       end


        MEM_DATOS_CHECK : begin
            o_tx_start = 0;
            o_control_database = 0;
            o_data_tx = i_dato_mem_datos;
            o_soft_reset = 1; //Logica por nivel bajo.
            o_write_mem_programa = 0; //Write es en 1.
            o_addr_mem_programa = 0;
            o_next_dato_mem_programa = 0;
            reg_next_modo_ejecucion = o_modo_ejecucion;// Continuo en cero, paso a paso en 1.
            o_enable_mem_programa = 0;
            o_rsta_mem = 0;
            o_regcea_mem = 0;
            o_led = 0;
            o_enable_PC = 0;
            o_enable_pipeline = 0;
            o_control_mux_addr_mem_top_if = 0;
            
            o_control_write_read_mem_datos = 1;
            o_control_address_mem_datos = 1;
            o_enable_mem_datos = 1;
            o_reg_read_to_register_file = 0;  
        end

        ESPERA_MEM_DATOS_CHECK_ACK : begin // Envia a PC el fin de envio de datos a memoria.
            o_tx_start = 0;
            o_control_database = 0;
            o_data_tx = 8'b00001011;
            o_soft_reset = 1; //Logica por nivel bajo.
            o_write_mem_programa = 0; //Write es en 1.
            o_addr_mem_programa = 0;
            o_next_dato_mem_programa = 0;
            reg_next_modo_ejecucion = o_modo_ejecucion;// Continuo en cero, paso a paso en 1.
            o_enable_mem_programa = 0;
            o_rsta_mem = 0;
            o_regcea_mem = 0;
            o_led = 0;
            o_enable_PC = 0;
            o_enable_pipeline = 0;
            o_control_mux_addr_mem_top_if = 0;
            
            o_control_write_read_mem_datos = 1;
            o_control_address_mem_datos = 1;
            o_enable_mem_datos = 0;
            o_reg_read_to_register_file = 0;  
        end


        default : begin
            o_tx_start = 0;
            o_data_tx = 0;
            o_soft_reset = 1; //Logica por nivel bajo.
            o_write_mem_programa = 0; //Write es en 1.
            o_addr_mem_programa = 0;
            o_next_dato_mem_programa = 0;
            reg_next_modo_ejecucion = 0; // Continuo.
            o_enable_mem_programa = 0;
            o_rsta_mem = 1;
            o_regcea_mem = 1;
            o_led = 1;
            o_enable_PC = 0;
            o_enable_pipeline = 0;
            o_control_mux_addr_mem_top_if = 1;
            o_control_database = 0;
            o_control_write_read_mem_datos = 0;
            o_control_address_mem_datos = 0;
            o_enable_mem_datos = 0;
            o_reg_read_to_register_file = 0;  
       end

 endcase
end

endmodule
