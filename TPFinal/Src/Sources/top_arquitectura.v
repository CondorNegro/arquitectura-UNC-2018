`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// TOP.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////



`define WIDTH_WORD_TOP                          8       // Tamanio de palabra.    
`define FREC_CLK_MHZ                            50.0       // Frecuencia del clock en MHZ.
`define BAUD_RATE_TOP                           9600       // Baud rate.
`define CANT_BIT_STOP_TOP                       2       // Cantidad de bits de parada en trama uart.
`define RAM_WIDTH_DATOS                         32
`define RAM_WIDTH_PROGRAMA                      32
`define RAM_PERFORMANCE_DATOS                   "LOW_LATENCY"
`define RAM_PERFORMANCE_PROGRAMA                "LOW_LATENCY"
`define INIT_FILE_DATOS                         ""
`define INIT_FILE_PROGRAMA                      ""
`define RAM_DEPTH_DATOS                         1024
`define RAM_DEPTH_PROGRAMA                      1024
`define CANT_ESTADOS_DEBUG_UNIT                 34
`define ADDR_MEM_PROGRAMA_LENGTH                10
`define ADDR_MEM_DATOS_LENGTH                   10
`define LONG_INSTRUCCION                        32
`define CANT_BITS_CONTROL_DATABASE_TOP          4
`define CANT_SWITCHES                           4
`define CANT_BITS_REGISTROS_TOP                 32
`define CANT_BITS_ALU_OP_TOP                    2
`define CANT_BITS_ALU_CONTROL_TOP               4
`define CANT_REGISTROS_TOP                      32 
`define CANT_BITS_IMMEDIATE_TOP                 16
`define CANT_BITS_ESPECIAL_TOP                  6
`define CANT_BITS_CEROS_TOP                     5
`define CANT_BITS_ID_LSB_TOP                    6
`define CANT_BITS_INSTRUCTION_INDEX_BRANCH_TOP  26
`define CANT_BITS_FLAG_BRANCH_TOP               3 
`define CANT_BITS_ADDR_REGISTROS                5
`define HALT_INSTRUCTION_TOP                    32'hFFFFFFFF

module top_arquitectura(
  i_clock_top, 
  i_reset,
  i_switches,
  uart_txd_in,
  uart_rxd_out,
  //jc
  o_leds 
  );



// Parametros
parameter WIDTH_WORD_TOP    = `WIDTH_WORD_TOP;
parameter FREC_CLK_MHZ      = `FREC_CLK_MHZ;
parameter BAUD_RATE_TOP     = `BAUD_RATE_TOP;
parameter CANT_BIT_STOP_TOP = `CANT_BIT_STOP_TOP;
parameter HALT_INSTRUCTION_TOP      = `HALT_INSTRUCTION_TOP;
parameter RAM_WIDTH_DATOS           = `RAM_WIDTH_DATOS;
parameter RAM_WIDTH_PROGRAMA        =  `RAM_WIDTH_PROGRAMA;
parameter RAM_PERFORMANCE_DATOS     =  `RAM_PERFORMANCE_DATOS;
parameter RAM_PERFORMANCE_PROGRAMA  = `RAM_PERFORMANCE_PROGRAMA;
parameter INIT_FILE_DATOS           =   `INIT_FILE_DATOS;
parameter INIT_FILE_PROGRAMA        =  `INIT_FILE_PROGRAMA;     
parameter RAM_DEPTH_DATOS           =  `RAM_DEPTH_DATOS;
parameter RAM_DEPTH_PROGRAMA        =  `RAM_DEPTH_PROGRAMA;
parameter CANT_ESTADOS_DEBUG_UNIT   =  `CANT_ESTADOS_DEBUG_UNIT;
parameter ADDR_MEM_PROGRAMA_LENGTH  =  `ADDR_MEM_PROGRAMA_LENGTH;
parameter ADDR_MEM_DATOS_LENGTH     =  `ADDR_MEM_DATOS_LENGTH;
parameter LONG_INSTRUCCION          =  `LONG_INSTRUCCION;
parameter CANT_BITS_CONTROL_DATABASE_TOP = `CANT_BITS_CONTROL_DATABASE_TOP;
parameter CANT_SWITCHES             =   `CANT_SWITCHES;
parameter CANT_BITS_REGISTROS_TOP   = `CANT_BITS_REGISTROS_TOP;
parameter CANT_BITS_ALU_OP_TOP      = `CANT_BITS_ALU_OP_TOP;
parameter CANT_BITS_ALU_CONTROL_TOP = `CANT_BITS_ALU_CONTROL_TOP;
parameter CANT_REGISTROS_TOP        = `CANT_REGISTROS_TOP; 
parameter CANT_BITS_IMMEDIATE_TOP   = `CANT_BITS_IMMEDIATE_TOP;
parameter CANT_BITS_ESPECIAL_TOP    = `CANT_BITS_ESPECIAL_TOP;
parameter CANT_BITS_CEROS_TOP       = `CANT_BITS_CEROS_TOP;
parameter CANT_BITS_ID_LSB_TOP      = `CANT_BITS_ID_LSB_TOP;
parameter CANT_BITS_INSTRUCTION_INDEX_BRANCH_TOP = `CANT_BITS_INSTRUCTION_INDEX_BRANCH_TOP;
parameter CANT_BITS_FLAG_BRANCH_TOP = `CANT_BITS_FLAG_BRANCH_TOP;
parameter CANT_BITS_ADDR_REGISTROS  = `CANT_BITS_ADDR_REGISTROS; 

// Entradas - Salidas
input i_clock_top;                              // Clock.
input i_reset;                                  // Reset.
input [CANT_SWITCHES - 1 : 0] i_switches;       // Switches.
input uart_txd_in;                              // Transmisor de PC.
output uart_rxd_out;                            // Receptor de PC.
output [3 : 0] o_leds;                          // Leds.
//output [7:0] jc;



// Wires.
wire i_clock;
wire [WIDTH_WORD_TOP - 1 : 0]   wire_data_rx;
wire [WIDTH_WORD_TOP - 1 : 0]   wire_data_tx;
wire wire_tx_done;
wire wire_rx_done;
wire wire_tx_start;
wire wire_rate_baud_generator;
wire wire_soft_reset;


// Instruction fetch.
wire [ADDR_MEM_PROGRAMA_LENGTH - 1 : 0] wire_addr_mem_programa;
wire [RAM_WIDTH_PROGRAMA - 1 : 0] wire_data_mem_programa_input;
wire [RAM_WIDTH_PROGRAMA - 1 : 0] wire_data_mem_programa_output;
wire wire_wr_rd_mem_prog;
wire wire_wr_rd_mem_datos;
wire [RAM_WIDTH_DATOS - 1 : 0] wire_datos_in_mem_data;
wire [RAM_WIDTH_DATOS - 1 : 0] wire_datos_out_mem_data;
wire [ADDR_MEM_DATOS_LENGTH - 1 : 0] wire_addr_mem_datos;
wire wire_soft_reset_ack;
wire wire_soft_reset_ack_prog;
wire wire_soft_reset_ack_datos;
wire wire_modo_ejecucion;
wire [ADDR_MEM_DATOS_LENGTH - 1 : 0] wire_addr_control_bit_sucio;
wire wire_bit_sucio;
wire wire_enable_mem;
wire wire_rsta_mem;
wire wire_regcea_mem;
wire [LONG_INSTRUCCION - 1 : 0] wire_instruction_fetch;
wire [CANT_BITS_CONTROL_DATABASE_TOP - 1 : 0] wire_control_database;
wire wire_enable_PC;
wire wire_control_mux_output_IF;
wire wire_control_mux_addr_mem_IF;
wire wire_control_mux_PC;
wire [LONG_INSTRUCCION - 1 : 0] wire_dato_database;
wire [ADDR_MEM_PROGRAMA_LENGTH - 1 : 0] wire_branch_dir;
wire [ADDR_MEM_PROGRAMA_LENGTH - 1 : 0] wire_contador_ciclos;
wire [ADDR_MEM_PROGRAMA_LENGTH - 1 : 0] wire_contador_programa;
wire [ADDR_MEM_PROGRAMA_LENGTH - 1 : 0] wire_adder_contador_programa;

// Instruction decode.

wire wire_enable_pipeline;

wire wire_control_write_reg_ID;
wire [CANT_BITS_REGISTROS_TOP - 1 : 0] wire_data_write_ID;
wire [CANT_BITS_ADDR_REGISTROS - 1 : 0] wire_reg_write_ID;
wire wire_control_mux_PC_to_database;
wire [ADDR_MEM_PROGRAMA_LENGTH - 1 : 0] wire_branch_dir_to_database;
wire [CANT_BITS_REGISTROS_TOP - 1 : 0] wire_data_A;
wire [CANT_BITS_REGISTROS_TOP - 1 : 0] wire_data_B;
wire [CANT_BITS_REGISTROS_TOP - 1 : 0] wire_extension_signo_constante;
wire [CANT_BITS_ADDR_REGISTROS - 1 : 0] wire_reg_rs;
wire [CANT_BITS_ADDR_REGISTROS - 1 : 0] wire_reg_rt;
wire [CANT_BITS_ADDR_REGISTROS - 1 : 0] wire_reg_rd;
wire wire_RegDst;
wire wire_RegWrite;
wire wire_ALUSrc;
wire [CANT_BITS_ALU_OP_TOP - 1 : 0] wire_ALUOp;
wire wire_MemRead;
wire wire_MemWrite;
wire wire_MemtoReg;
wire [CANT_BITS_FLAG_BRANCH_TOP - 1 : 0] wire_flag_branch;
wire [CANT_BITS_ALU_CONTROL_TOP - 1 : 0] wire_ALUCtrl; 
wire [ADDR_MEM_PROGRAMA_LENGTH - 1 : 0] wire_out_adder_pc_ID_EX;


// Ejecucion.

wire wire_EX_to_MEM_RegWrite;
wire wire_EX_to_MEM_MemRead;
wire wire_EX_to_MEM_MemWrite;
wire wire_EX_to_MEM_MemtoReg;
wire [CANT_BITS_REGISTROS_TOP - 1 : 0] wire_resultado_ALU;
wire [ADDR_MEM_DATOS_LENGTH - 1 : 0] wire_EX_to_MEM_data_write_mem;
wire [CANT_BITS_ADDR_REGISTROS - 1 : 0] wire_registro_destino;

// Asignaciones de wires.

//Borrar y dejar el segundo 
assign wire_soft_reset_ack = wire_soft_reset_ack_prog;
//assign wire_soft_reset_ack = wire_soft_reset_ack_prog | wire_soft_reset_ack_datos;


 

//wire prueba;
//assign jc[0] = prueba;
//assign uart_rxd_out = prueba;
//assign o_leds[1] = 1'b0;
//assign o_leds[2] = 1'b0;
assign o_leds[3] = 1'b0;


// Modulo clock_wizard.

clk_wiz_0
u_clk_wiz_0_1
(
  .clk_out1(i_clock),
  .reset(~i_switches[0]),
  .locked(),
  .clk_in1(i_clock_top)
);


// Modulo debug_unit.

debug_unit
    #(
        .CANTIDAD_ESTADOS (CANT_ESTADOS_DEBUG_UNIT),      
        .ADDR_MEM_LENGTH (ADDR_MEM_PROGRAMA_LENGTH),                 
        .LONGITUD_INSTRUCCION (LONG_INSTRUCCION),              
        .OUTPUT_WORD_LENGTH (WIDTH_WORD_TOP),   
        .HALT_INSTRUCTION   (HALT_INSTRUCTION_TOP),
        .CANT_BITS_CONTROL_DATABASE (CANT_BITS_CONTROL_DATABASE_TOP)          
     ) 
   u_debug_unit1    // Una sola instancia de este modulo
   (
    .i_clock (i_clock),
    .i_reset (i_reset),
    .i_tx_done (wire_tx_done),
    .i_rx_done (wire_rx_done),
    .i_data_rx (wire_data_rx),
    .i_soft_reset_ack (wire_soft_reset_ack),
    .i_instruction_fetch (wire_instruction_fetch),
    .i_dato_database (wire_dato_database),
    .o_tx_start (wire_tx_start),
    .o_data_tx (wire_data_tx),
    .o_soft_reset (wire_soft_reset),
    .o_write_mem_programa (wire_wr_rd_mem_prog),
    .o_addr_mem_programa (wire_addr_mem_programa),
    .o_dato_mem_programa (wire_data_mem_programa_input),
    .o_modo_ejecucion (wire_modo_ejecucion),
    .o_enable_mem (wire_enable_mem),
    .o_rsta_mem (wire_rsta_mem),
    .o_regcea_mem (wire_regcea_mem),
    .o_enable_PC (wire_enable_PC),
    .o_control_mux_addr_mem_top_if (wire_control_mux_addr_mem_IF),
    .o_control_database (wire_control_database),
    .o_enable_pipeline (wire_enable_pipeline),
    .o_led (o_leds[0])
   );


// Modulo baud_rate_generator  
baud_rate_generator
    #(
        .BAUD_RATE (BAUD_RATE_TOP),
        .FREC_CLOCK_MHZ (FREC_CLK_MHZ)
    ) 
    u_baud_rate_generator1    // Una sola instancia de este modulo
    (
    .i_clock (i_clock),
    .i_reset (i_reset),
    .o_rate (wire_rate_baud_generator)
    );
      
// Modulo receptor      
rx
    #(
        .WIDTH_WORD (WIDTH_WORD_TOP),
        .CANT_BIT_STOP (CANT_BIT_STOP_TOP)
    ) 
    u_rx1    // Una sola instancia de este modulo
    (
    .i_clock (i_clock),
    .i_rate (wire_rate_baud_generator),
    .i_bit_rx (uart_txd_in),
    .i_reset (i_reset),
    .o_rx_done (wire_rx_done),
    .o_data_out (wire_data_rx)
    );


// Modulo transmisor.
tx
    #(
        .WIDTH_WORD_TX (WIDTH_WORD_TOP),
        .CANT_BIT_STOP (CANT_BIT_STOP_TOP)
    ) 
    u_tx1    // Una sola instancia de este modulo
    (
    .i_clock (i_clock),
    .i_rate (wire_rate_baud_generator),
    .i_reset (i_reset),
    .i_data_in (wire_data_tx),
    .i_tx_start (wire_tx_start),
    .o_bit_tx (uart_rxd_out),
    .o_tx_done (wire_tx_done)
    );


// Modulo top de la etapa instruction fetch.
top_if
  #(
      .RAM_WIDTH_PROGRAMA (RAM_WIDTH_PROGRAMA),
      .RAM_PERFORMANCE_PROGRAMA (RAM_PERFORMANCE_PROGRAMA),
      .INIT_FILE_PROGRAMA (INIT_FILE_PROGRAMA),
      .RAM_DEPTH_PROGRAMA (RAM_DEPTH_PROGRAMA),
      .CANT_BITS_ADDR (ADDR_MEM_PROGRAMA_LENGTH)
   )
  u_top_if_1
  (
    .i_clock (i_clock),
    .i_soft_reset (wire_soft_reset),
    .i_enable_contador_PC (wire_enable_PC),
    .i_enable_mem (wire_enable_mem),
    .i_write_read_mem (wire_wr_rd_mem_prog),
    .i_rsta_mem (wire_rsta_mem),
    .i_regcea_mem (wire_regcea_mem),
    .i_addr_mem_programa (wire_addr_mem_programa),
    .i_data_mem_programa (wire_data_mem_programa_input),
    .i_control_mux_PC (wire_control_mux_PC),
    .i_control_mux_addr_mem (wire_control_mux_addr_mem_IF),
    .i_branch_dir (wire_branch_dir),
    .i_enable_pipeline (wire_enable_pipeline),
    .o_instruction (wire_instruction_fetch),
    .o_direccion_adder_pc (wire_adder_contador_programa),
    .o_contador_programa (wire_contador_programa),
    .o_led_mem (o_leds[1]),
    .o_reset_ack_mem (wire_soft_reset_ack_prog)
  );


// Modulo top de la etapa de instruction decode.
top_id
    #(
        .LENGTH_INSTRUCTION (LONG_INSTRUCCION),
        .CANT_REGISTROS (CANT_REGISTROS_TOP),
        .CANT_BITS_ADDR (ADDR_MEM_PROGRAMA_LENGTH),
        .CANT_BITS_REGISTROS (CANT_BITS_REGISTROS_TOP),
        .CANT_BITS_IMMEDIATE (CANT_BITS_IMMEDIATE_TOP),
        .CANT_BITS_ESPECIAL (CANT_BITS_ESPECIAL_TOP),
        .CANT_BITS_CEROS (CANT_BITS_CEROS_TOP),
        .CANT_BITS_ID_LSB (CANT_BITS_ID_LSB_TOP),
        .CANT_BITS_INSTRUCTION_INDEX_BRANCH (CANT_BITS_INSTRUCTION_INDEX_BRANCH_TOP),
        .CANT_BITS_FLAG_BRANCH (CANT_BITS_FLAG_BRANCH_TOP),
        .CANT_BITS_ALU_OP (CANT_BITS_ALU_OP_TOP),
        .CANT_BITS_ALU_CONTROL (CANT_BITS_ALU_CONTROL_TOP)  
     ) 
    u_top_id_1    // Una sola instancia de este modulo.
    (
        .i_clock (i_clock),
        .i_soft_reset (wire_soft_reset),

        .i_instruction (wire_instruction_fetch),
        .i_out_adder_pc (wire_adder_contador_programa),

        .i_control_write_reg (wire_control_write_reg_ID),
        .i_reg_write (wire_reg_write_ID),
        .i_data_write (wire_data_write_ID),
        .i_enable_pipeline (wire_enable_pipeline),
        .i_enable_etapa (wire_enable_PC),
        .o_out_adder_pc (wire_out_adder_pc_ID_EX),
        .o_branch_dir (wire_branch_dir),
        .o_branch_control (wire_control_mux_PC),
        .o_branch_dir_to_database (wire_branch_dir_to_database),
        .o_branch_control_to_database (wire_control_mux_PC_to_database),
        .o_data_A (wire_data_A),
        .o_data_B (wire_data_B),
        .o_extension_signo_constante (wire_extension_signo_constante),
        .o_reg_rs (wire_reg_rs),
        .o_reg_rt (wire_reg_rt),
        .o_reg_rd (wire_reg_rd),

        .o_RegDst (wire_RegDst),
        .o_RegWrite (wire_RegWrite),
        .o_ALUSrc (wire_ALUSrc),
        .o_ALUOp (wire_ALUOp),
        .o_MemRead (wire_MemRead),
        .o_MemWrite (wire_MemWrite),
        .o_MemtoReg (wire_MemtoReg),
        .o_ALUCtrl (wire_ALUCtrl),   

        .o_led (o_leds[2])
    );


// Modulo top de la etapa de ejecucion de la instruccion.
top_ejecucion
    #(
        .WIDTH_DATA_MEM (RAM_WIDTH_DATOS),
        .CANT_REGISTROS (CANT_REGISTROS_TOP),
        .CANT_BITS_ADDR  (ADDR_MEM_PROGRAMA_LENGTH),
        .CANT_BITS_REGISTROS (CANT_BITS_REGISTROS_TOP),
        .CANT_BITS_ALU_CONTROL (CANT_BITS_ALU_CONTROL_TOP)
        
     ) 
    u_top_ejecucion_1    // Una sola instancia de este modulo.
    (
        .i_clock (i_clock),
        .i_soft_reset (wire_soft_reset),
        .i_enable_pipeline (wire_enable_pipeline),
        .i_adder_pc (wire_out_adder_pc_ID_EX),
        .i_data_A (wire_data_A),
        .i_data_B (wire_data_B),
        .i_extension_signo_constante (wire_extension_signo_constante),
        .i_reg_rs (wire_reg_rs),
        .i_reg_rt (wire_reg_rt),
        .i_reg_rd (wire_reg_rd),
        .i_RegDst (wire_RegDst),
        .i_RegWrite (wire_RegWrite),
        .i_ALUSrc (wire_ALUSrc),
        .i_MemRead (wire_MemRead),
        .i_MemWrite (wire_MemWrite),
        .i_MemtoReg (wire_MemtoReg),
        .i_ALUCtrl (wire_ALUCtrl), 
        .o_RegWrite (wire_EX_to_MEM_RegWrite),
        .o_MemRead (wire_EX_to_MEM_MemRead),
        .o_MemWrite (wire_EX_to_MEM_MemWrite),
        .o_MemtoReg (wire_EX_to_MEM_MemtoReg),
        .o_result (wire_resultado_ALU),
        .o_data_write_to_mem (wire_EX_to_MEM_data_write_mem),
        .o_registro_destino (wire_registro_destino),
        .o_led ()
    );


// Modulo top de la etapa write back de la instruccion.
/**

top_write_back
    #(
        .CANT_REGISTROS (CANT_REGISTROS_TOP),
        .CANT_BITS_REGISTROS (CANT_BITS_REGISTROS_TOP)
    )
    u_top_write_back_1
    (
        .i_registro_destino (),
        .i_data_mem (),
        .i_data_alu (),
        .i_RegWrite (),
        .i_MemtoReg (),
        .o_registro_destino (wire_reg_write_ID),
        .o_RegWrite (wire_control_write_reg_ID),
        .o_data_write (wire_data_write_ID),
        .o_led ()
    );

**/  


// Modulo contador de ciclos.
contador_ciclos
    #(
        .CONTADOR_LENGTH (ADDR_MEM_PROGRAMA_LENGTH)
     )
    u_contador_ciclos_1
    (
      .i_clock (i_clock),
      .i_soft_reset (wire_soft_reset),
      .i_enable (wire_enable_PC),
      .o_cuenta (wire_contador_ciclos)
    );




// Modulo que almacena los datos del MIPS para enviar a PC.
database
    #(
        .ADDR_LENGTH (ADDR_MEM_PROGRAMA_LENGTH),
        .LONGITUD_INSTRUCCION (LONG_INSTRUCCION),
		.CANT_BITS_CONTROL (CANT_BITS_CONTROL_DATABASE_TOP),
        .CANT_BITS_REGISTROS (CANT_BITS_REGISTROS_TOP),
        .CANT_BITS_ALU_OP (CANT_BITS_ALU_OP_TOP),
        .CANT_BITS_ALU_CONTROL (CANT_BITS_ALU_CONTROL_TOP),
        .CANT_REGISTROS (CANT_REGISTROS_TOP)
     )
    u_database_1
    (
        .i_clock (i_clock),
        .i_soft_reset (wire_soft_reset),
        .i_control (wire_control_database),
        .i_pc (wire_contador_programa),
        .i_contador_ciclos (wire_contador_ciclos),
		.i_adder_pc (wire_adder_contador_programa),
		.i_instruction_fetch (wire_instruction_fetch),
        .i_branch_dir (wire_branch_dir_to_database),
        .i_branch_control (wire_control_mux_PC_to_database),
        .i_data_A (wire_data_A),
        .i_data_B (wire_data_B),
        .i_extension_signo_constante (wire_extension_signo_constante),
        .i_reg_rs (wire_reg_rs),
        .i_reg_rt (wire_reg_rt),
        .i_reg_rd (wire_reg_rd),
        .i_RegDst (wire_RegDst),
        .i_RegWrite (wire_RegWrite),
        .i_ALUSrc (wire_ALUSrc),
        .i_ALUOp (wire_ALUOp),
        .i_MemRead (wire_MemRead),
        .i_MemWrite (wire_MemWrite),
        .i_MemtoReg (wire_MemtoReg),
        .i_ALUCtrl (wire_ALUCtrl),
        .o_dato (wire_dato_database)
    );

// Memorias.

/**memoria_datos
   #(
        .RAM_WIDTH (RAM_WIDTH_DATOS),
        .RAM_PERFORMANCE (RAM_PERFORMANCE_DATOS),
        .INIT_FILE (INIT_FILE_DATOS),
        .RAM_DEPTH (RAM_DEPTH_DATOS)
    ) 
   u_memoria_datos_1    
   (
     .i_clk (i_clock),
     .i_addr (wire_addr_mem_datos),
     .i_data (wire_datos_in_mem_data),           
     .i_wea (wire_wr_rd_mem_datos),             
     .i_ena (wire_enable_mem),              
     .i_rsta (wire_rsta_mem),             
     .i_regcea (wire_regcea_mem),           
     .i_soft_reset (wire_soft_reset),
     .i_bit_sucio (wire_bit_sucio),      
     .o_data (wire_datos_out_mem_data),           
     .o_reset_ack (wire_soft_reset_ack_datos),
     .o_addr_bit_sucio (wire_addr_control_bit_sucio)    
   );**/

/*memoria_programa
    #(
        .RAM_WIDTH (RAM_WIDTH_PROGRAMA),
        .RAM_PERFORMANCE (RAM_PERFORMANCE_PROGRAMA),
        .INIT_FILE (INIT_FILE_PROGRAMA),
        .RAM_DEPTH (RAM_DEPTH_PROGRAMA)
    )
    u_memoria_programa_1
    (
        .i_clk (i_clock),
        .i_addr (wire_addr_mem_programa),
        .i_data (wire_data_mem_programa_input),           
        .i_wea (wire_wr_rd_mem_prog),              
        .i_ena (wire_enable_mem),             
        .i_rsta (wire_rsta_mem),             
        .i_regcea (wire_regcea_mem),           
        .i_soft_reset (wire_soft_reset),       
        .o_data (wire_data_mem_programa_output),           
        .o_reset_ack (wire_soft_reset_ack_prog),
        .o_led (o_leds[1])       
    );*/

// Control de bit de sucio en memoria de datos.

/**control_bit_sucio_mem_data
    #(
        .RAM_DEPTH (RAM_DEPTH_DATOS)
    )
    u_control_bit_sucio_mem_data_1
    (
        .i_addr (wire_addr_control_bit_sucio),                         
        .i_clk (i_clock),                         
        .i_wea (wire_wr_rd_mem_datos),                            
        .i_ena (wire_enable_mem), 
        .i_soft_reset (wire_soft_reset),                           
        .i_soft_reset_ack_mem_datos (wire_soft_reset_ack_datos),      
        .o_bit_sucio (wire_bit_sucio) 
    );**/

endmodule
