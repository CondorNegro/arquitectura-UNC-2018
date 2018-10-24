`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 3. BIP I.
// TOP.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////



`define WIDTH_WORD_TOP          8       // Tamanio de palabra.    
`define FREC_CLK_MHZ        100.0       // Frecuencia del clock en MHZ.
`define BAUD_RATE_TOP        9600       // Baud rate.
`define CANT_BIT_STOP_TOP       2       // Cantidad de bits de parada en trama uart.     
`define PC_CANT_BITS           11       // Cantidad de bits del PC.
`define SUM_DIR                 1       // Cantidad a sumar al PC para obtener la direccion siguiente.
`define OPCODE_LENGTH           5       // Cantidad de bits del codigo de operacion.
`define CC_LENGTH              11       //  Cantidad de bits del contador de ciclos.
`define ACC_LENGTH             16       //  Cantidad de bits del acumulador.
`define HALT_OPCODE             0       //  Opcode de la instruccion HALT.
`define OPERANDO_LENGTH        11
`define OPERANDO_FINAL_LENGHT  16
`define RAM_WIDTH_DATOS        16
`define RAM_WIDTH_PROGRAMA     16
`define RAM_PERFORMANCE_DATOS    "LOW_LATENCY"
`define RAM_PERFORMANCE_PROGRAMA "HIGH_PERFORMANCE"
`define INIT_FILE_DATOS        ""
`define INIT_FILE_PROGRAMA     "C:/Users/gopez/Desktop/UniversidadProyectos/ArquitecturaDeComputadoras/Repo/arquitectura-UNC-2018/TP3/Src/Script/init_ram_file.txt"      
//`define INIT_FILE_PROGRAMA  "/home/matias/Documentos/arqui/arquitectura-UNC-2018/TP3/Src/Script/init_ram_file.txt"
`define RAM_DEPTH_DATOS      1024
`define RAM_DEPTH_PROGRAMA   2048

module top_arquitectura(
  i_clock, 
  i_reset,
  uart_txd_in,
  uart_rxd_out
  //jc
  //o_leds 
  );



// Parametros
parameter WIDTH_WORD_TOP    = `WIDTH_WORD_TOP;
parameter FREC_CLK_MHZ      = `FREC_CLK_MHZ;
parameter BAUD_RATE_TOP     = `BAUD_RATE_TOP;
parameter CANT_BIT_STOP_TOP = `CANT_BIT_STOP_TOP;
parameter PC_CANT_BITS      = `PC_CANT_BITS;
parameter SUM_DIR           = `SUM_DIR;
parameter OPCODE_LENGTH     = `OPCODE_LENGTH;
parameter CC_LENGTH         = `CC_LENGTH;
parameter ACC_LENGTH        = `ACC_LENGTH;
parameter HALT_OPCODE       = `HALT_OPCODE;
parameter OPERANDO_LENGTH   = `OPERANDO_LENGTH;         
parameter OPERANDO_FINAL_LENGHT     = `OPERANDO_FINAL_LENGHT;    
parameter RAM_WIDTH_DATOS           = `RAM_WIDTH_DATOS;
parameter RAM_WIDTH_PROGRAMA        =  `RAM_WIDTH_PROGRAMA;
parameter RAM_PERFORMANCE_DATOS     =  `RAM_PERFORMANCE_DATOS;
parameter RAM_PERFORMANCE_PROGRAMA  = `RAM_PERFORMANCE_PROGRAMA;
parameter INIT_FILE_DATOS           =   `INIT_FILE_DATOS;
parameter INIT_FILE_PROGRAMA        =  `INIT_FILE_PROGRAMA;     
parameter RAM_DEPTH_DATOS           =  `RAM_DEPTH_DATOS;
parameter RAM_DEPTH_PROGRAMA        =  `RAM_DEPTH_PROGRAMA;


// Entradas - Salidas
input i_clock;                                  // Clock.
input i_reset;                                  // Reset.
input uart_txd_in;                              // Transmisor de PC.
output uart_rxd_out;                            // Receptor de PC.
//output [4 - 1 : 0] o_leds;                    // Leds.
//output [7:0] jc;



// Wires.

wire [WIDTH_WORD_TOP - 1 : 0]   wire_data_rx;
wire [WIDTH_WORD_TOP - 1 : 0]   wire_data_tx;
wire wire_tx_done;
wire wire_rx_done;
wire wire_tx_start;
wire wire_rate_baud_generator;
wire wire_soft_reset;
wire [PC_CANT_BITS - 1 : 0] wire_addr_mem_programa;
wire [RAM_WIDTH_PROGRAMA - 1 : 0] wire_data_mem_programa;
wire [1 : 0]  wire_selA;
wire wire_selB;
wire wire_wrACC;
wire [OPCODE_LENGTH - 1 : 0] wire_opcode_instruction_decoder;
wire wire_wr_rd_mem;
wire [PC_CANT_BITS - 1 : 0] wire_cuenta_ciclos;
wire [ACC_LENGTH - 1 : 0] wire_valor_ACC;
wire [RAM_WIDTH_DATOS - 1 : 0] wire_datos_out_mem_data;
wire [PC_CANT_BITS - 1 : 0] wire_addr_mem_datos;

//wire prueba;
//assign jc[0] = prueba;
//assign uart_rxd_out = prueba;

// Modulo interface_circuit.

interface_circuit
    #(
        .CANT_BITS_OPCODE (OPCODE_LENGTH),      //  Cantidad de bits del opcode.
        .CC_LENGTH (CC_LENGTH),                 //  Cantidad de bits del contador de ciclos.
        .ACC_LENGTH (ACC_LENGTH),               //  Cantidad de bits del acumulador.
        .OUTPUT_WORD_LENGTH (WIDTH_WORD_TOP),   //  Cantidad de bits de la palabra a transmitir.
        .HALT_OPCODE (HALT_OPCODE)              //  Opcode de la instruccion HALT.
     ) 
   u_interface_circuit1    // Una sola instancia de este modulo
   (
    .i_clock (i_clock),
    .i_reset (i_reset),
    .i_tx_done (wire_tx_done),
    .i_rx_done (wire_rx_done),
    .i_data_rx (wire_data_rx),
    .i_opcode (wire_opcode_instruction_decoder),
    .i_CC (wire_cuenta_ciclos),
    .i_ACC (wire_valor_ACC),
    .o_tx_start (wire_tx_start),
    .o_data_tx (wire_data_tx),
    .o_soft_reset (wire_soft_reset)
   //.o_prueba (prueba)
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


// Modulo ALU.

control
    #(
        .PC_CANT_BITS (PC_CANT_BITS),   // Cantidad de bits del PC.
        .SUM_DIR (SUM_DIR),             // Cantidad a sumar al PC para obtener la direccion siguiente.
        .OPCODE_LENGTH (OPCODE_LENGTH)  // Cantidad de bits del codigo de operacion
    )
    u_control1    // Una sola instancia de este modulo
    (
        .i_clock (i_clock),
        .i_soft_reset (wire_soft_reset),
        .i_mem_data_opcode (wire_data_mem_programa [RAM_WIDTH_PROGRAMA - 1 : RAM_WIDTH_PROGRAMA - OPCODE_LENGTH]),
        .o_addr_mem (wire_addr_mem_programa),
        .o_selA (wire_selA),
        .o_selB (wire_selB),
        .o_wrAcc (wire_wrACC),
        .o_opCode (wire_opcode_instruction_decoder),
        .o_wr_rd_mem (wire_wr_rd_mem)
    );
    

datapath
    #(
        .OPERANDO_LENGTH (OPERANDO_LENGTH),                 // Cantidad de bits del operando.
        .OPERANDO_FINAL_LENGHT (OPERANDO_FINAL_LENGHT),     // Cantidad de bits del operando con extension de signo.
        .OPCODE_LENGTH (OPCODE_LENGTH)                      // Cantidad de bits del opcode.
    )
    u_datapath1
    (
        .i_clock (i_clock),
        .i_reset (wire_soft_reset),
        .i_selA (wire_selA),
        .i_selB (wire_selB),
        .i_wrACC (wire_wrACC),
        .i_opcode (wire_opcode_instruction_decoder),
        .i_operando (wire_data_mem_programa [RAM_WIDTH_PROGRAMA - OPCODE_LENGTH - 1 : 0]),
        .i_outmemdata (wire_datos_out_mem_data),
        .o_addr (wire_addr_mem_datos),
        .o_ACC (wire_valor_ACC)            
    );

memoria_datos
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
     .i_data (wire_valor_ACC),
     .wea (wire_wr_rd_mem),
     .o_data (wire_datos_out_mem_data)
   );

memoria_programa
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
        .o_data (wire_data_mem_programa)  
    );


contador_ciclos
    #(
        .CONTADOR_LENGTH (PC_CANT_BITS),
        .OPCODE_LENGTH(OPCODE_LENGTH)
    )
    u_contador_ciclos_1
    (
        .i_clock (i_clock),
        .i_reset (wire_soft_reset),
        .i_opcode(wire_opcode_instruction_decoder),
        .o_cuenta (wire_cuenta_ciclos)
    );

endmodule
