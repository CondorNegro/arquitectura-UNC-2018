 `timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Test bench del top.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////

`define WIDTH_WORD_TOP                          8       // Tamanio de palabra.    
`define FREC_CLK_MHZ                            50.0       // Frecuencia del clock en MHZ.
`define BAUD_RATE_TOP                           9600       // Baud rate.
`define CANT_BIT_STOP_TOP                       2       // Cantidad de bits de parada en trama uart.
`define HALT_INSTRUCTION                        32'hFFFFFFFF       //  Opcode de la instruccion HALT.
`define RAM_WIDTH_DATOS                         32
`define RAM_WIDTH_PROGRAMA                      32
`define RAM_PERFORMANCE_DATOS                   "LOW_LATENCY"
`define RAM_PERFORMANCE_PROGRAMA                "LOW_LATENCY"
`define INIT_FILE_DATOS                         ""
`define INIT_FILE_PROGRAMA                      ""
`define RAM_DEPTH_DATOS                         1024
`define RAM_DEPTH_PROGRAMA                      1024
`define CANT_ESTADOS_DEBUG_UNIT                 12
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
`define CANT_BITS_SELECT_BYTES_TOP              3


module test_bench_top_arquitectura_continuo();
       
   
   // Parametros
   parameter WIDTH_WORD_TOP    = `WIDTH_WORD_TOP;
   parameter FREC_CLK_MHZ      = `FREC_CLK_MHZ;
   parameter BAUD_RATE_TOP     = `BAUD_RATE_TOP;
   parameter CANT_BIT_STOP_TOP = `CANT_BIT_STOP_TOP;
   parameter HALT_INSTRUCTION          = `HALT_INSTRUCTION;   
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
   parameter CANT_BITS_SELECT_BYTES_TOP    = `CANT_BITS_SELECT_BYTES_TOP;  
   
   //Todo puerto de salida del modulo es un cable.
   //Todo puerto de estimulo o generacion de entrada es un registro.
   
   // Entradas.
   reg clock;                                  // Clock.
   reg hard_reset;                             // Reset.
   reg [CANT_SWITCHES - 1 : 0] reg_switches;
   reg uart_txd_in_reg;                        // Tx de PC.
   wire uart_rxd_out_wire;                     // Rx de PC.
   wire [3:0] wire_leds;                       // Leds de la placa.
   wire [2:0] wire_led_rgb;                    // Led RGB.
   
   
   initial    begin
		clock = 1'b0;
		hard_reset = 1'b0; // Reset en 0. (Normal cerrado el boton del reset).
		uart_txd_in_reg = 1'b1;
        reg_switches = 0;

		#2000 hard_reset = 1'b1; // Desactivo la accion del reset.
		#10 reg_switches = 1;

        /////////////////////////////////////////////////////////////////
        //MODO DEBUG
        ////////////////////////////////////////////////////////////////
        
        
        ///// SOFT RESET /////// 1
       
       //bit de inicio
       #52160 uart_txd_in_reg = 1'b0; // El 52160 sale de MODULO_CONTADOR_BAUD_RATE_GEN * 16 * PERIODO_CLOCK
       
       //primer dato - soft reset //0000 0000
       #52160 uart_txd_in_reg = 1'b0;
       #52160 uart_txd_in_reg = 1'b0;
       #52160 uart_txd_in_reg = 1'b0;
       #52160 uart_txd_in_reg = 1'b0;
       
       #52160 uart_txd_in_reg = 1'b0;
       #52160 uart_txd_in_reg = 1'b0;
       #52160 uart_txd_in_reg = 1'b0;
       #52160 uart_txd_in_reg = 1'b0;
       
       //bits de stop
       #52160 uart_txd_in_reg = 1'b1;
       #52160 uart_txd_in_reg = 1'b1;
       
       
        ///// ESPERA_PC_ACK /////// 2
      
      //bit de inicio
      #52160 uart_txd_in_reg = 1'b0;
      
      //soft reset ack //0000 0001
      #52160 uart_txd_in_reg = 1'b0;
      #52160 uart_txd_in_reg = 1'b0;
      #52160 uart_txd_in_reg = 1'b0;
      #52160 uart_txd_in_reg = 1'b0;
      
      #52160 uart_txd_in_reg = 1'b0;
      #52160 uart_txd_in_reg = 1'b0;
      #52160 uart_txd_in_reg = 1'b0;
      #52160 uart_txd_in_reg = 1'b1;
      
      //bits de stop
      #52160 uart_txd_in_reg = 1'b1;
      #52160 uart_txd_in_reg = 1'b1;



        



        /////////////////////////////////////
        // Primera instruccion (LWU R1,8{R2})
        /////////////////////////////////////

        // Dejo un intervalo de tiempo.
		#520080 uart_txd_in_reg = 1'b1;

        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;
        
        //primer dato - primera instruccion //1001 1100
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;
        
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        
        //bits de stop
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        // Dejo un intervalo de tiempo.
		#520080 uart_txd_in_reg = 1'b1;

        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;
        
        //segundo dato - primera instruccion //0100 0001
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;
        
        //bits de stop
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        // Dejo un intervalo de tiempo.
		#520080 uart_txd_in_reg = 1'b1;

        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;
        
        //tercer dato - primera instruccion //0000 0000
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        
        //bits de stop
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        // Dejo un intervalo de tiempo.
		#520080 uart_txd_in_reg = 1'b1;

        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;
        
        //cuarto dato - primera instruccion //0000 1000
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        
        //bits de stop
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;



        /////////////////////////////////////
        // Segunda instruccion (J 8)
        /////////////////////////////////////

        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;
        
        //primer dato - segunda instruccion //0000 1000
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        
        //bits de stop
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        // Dejo un intervalo de tiempo.
		#520080 uart_txd_in_reg = 1'b1;

        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;
        
        //segundo dato - segunda instruccion //0000 0000
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        
        //bits de stop
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        // Dejo un intervalo de tiempo.
		#520080 uart_txd_in_reg = 1'b1;

        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;
        
        //tercer dato - segunda instruccion //0000 0000
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        
        //bits de stop
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        // Dejo un intervalo de tiempo.
		#520080 uart_txd_in_reg = 1'b1;

        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;
        
        //cuarto dato - segunda instruccion //0000 1000
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        
        //bits de stop
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;






        ////////////////////////////
        // Tercera instruccion (HALT)
        ////////////////////////////
        
        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        //primer dato - tercera instruccion //0000 0000
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;
        
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;
        
        //bits de stop
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        //segundo dato - tercera instruccion //0000 0000
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;
        
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;
        
        //bits de stop
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        //tercer dato - tercera instruccion //0000 0000
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;
        
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;
        
        //bits de stop
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        //cuarto dato - tercera instruccion //0000 0000
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;
        
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;
        
        //bits de stop
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        



        ///// START MIPS ///////


        // Dejo un intervalo de tiempo.
        #520080 uart_txd_in_reg = 1'b1;

        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;


        //quinto dato - start MIPS //0000 0011 CONTINUO
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //bits de stop
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1; 




        // Dejo un intervalo de tiempo.
        #520080 uart_txd_in_reg = 1'b1;


        ///////////////////////////
        // Obtener valores del MIPS
        ///////////////////////////

        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART3
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;



        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART2
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;

        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;




        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART1
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;


        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART1
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;






        // Dejo un intervalo de tiempo.
        #520080 uart_txd_in_reg = 1'b1;


        ///////////////////////////
        // Obtener valores del MIPS
        ///////////////////////////

        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART3
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;



        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART2
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;

        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;




        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART1
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;


        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART1
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;











        ///////////////////////////
        // Obtener valores del MIPS
        ///////////////////////////

        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART3
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;



        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART2
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;

        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;




        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART1
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;


        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART1
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;






        // Dejo un intervalo de tiempo.
        #520080 uart_txd_in_reg = 1'b1;


        ///////////////////////////
        // Obtener valores del MIPS
        ///////////////////////////

        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART3
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;



        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART2
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;

        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;




        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART1
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;


        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART1
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;






        // Dejo un intervalo de tiempo.
        #520080 uart_txd_in_reg = 1'b1;


        ///////////////////////////
        // Obtener valores del MIPS
        ///////////////////////////

        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART3
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;



        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART2
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;

        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;




        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART1
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;


        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART1
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;






        // Dejo un intervalo de tiempo.
        #520080 uart_txd_in_reg = 1'b1;


        ///////////////////////////
        // Obtener valores del MIPS
        ///////////////////////////

        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART3
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;



        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART2
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;

        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;




        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART1
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;


        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART1
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;






        // Dejo un intervalo de tiempo.
        #520080 uart_txd_in_reg = 1'b1;


        ///////////////////////////
        // Obtener valores del MIPS
        ///////////////////////////

        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART3
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;



        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART2
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;

        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;




        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART1
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;


        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART1
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;



        // Dejo un intervalo de tiempo.
        #520080 uart_txd_in_reg = 1'b1;


        ///////////////////////////
        // Obtener valores del MIPS
        ///////////////////////////

        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART3
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;



        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART2
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;

        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;




        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART1
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;


        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART1
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;



        // Dejo un intervalo de tiempo.
        #520080 uart_txd_in_reg = 1'b1;


        ///////////////////////////
        // Obtener valores del MIPS
        ///////////////////////////

        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART3
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;



        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART2
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;

        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;




        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART1
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;


        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART1
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;





        // Dejo un intervalo de tiempo.
        #520080 uart_txd_in_reg = 1'b1;


        ///////////////////////////
        // Obtener valores del MIPS
        ///////////////////////////

        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART3
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;



        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART2
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;

        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;




        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART1
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;


        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART1
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;






        // Dejo un intervalo de tiempo.
        #520080 uart_txd_in_reg = 1'b1;


        ///////////////////////////
        // Obtener valores del MIPS
        ///////////////////////////

        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART3
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;



        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART2
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;

        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;




        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART1
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;


        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART1
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;




        ////////////////////////////////////////////



        // Dejo un intervalo de tiempo.
        #520080 uart_txd_in_reg = 1'b1;


        ///////////////////////////
        // Obtener valores del MIPS
        ///////////////////////////

        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART3
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;



        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART2
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;

        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;




        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART1
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;


        //bit de inicio
        #52160 uart_txd_in_reg = 1'b0;

        // PART1
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;
        #52160 uart_txd_in_reg = 1'b0;

        #52160 uart_txd_in_reg = 1'b1;
        #52160 uart_txd_in_reg = 1'b1;

        //dejo intervalo
        #52160 uart_txd_in_reg = 1'b1;
















































		// Prueba reset.
		#3000000 hard_reset = 1'b0; // Reset.
		#3000000 hard_reset = 1'b1; // Desactivo el reset.


		#5000000 $finish;
   end
   
   always #2.5 clock=~clock;  // Simulacion de clock.



//Modulo para pasarle los estimulos del banco de pruebas.
top_arquitectura
   #(
       .WIDTH_WORD_TOP             (WIDTH_WORD_TOP),
       .FREC_CLK_MHZ               (FREC_CLK_MHZ),
       .BAUD_RATE_TOP              (BAUD_RATE_TOP),
       .CANT_BIT_STOP_TOP          (CANT_BIT_STOP_TOP),
       .HALT_INSTRUCTION_TOP       (HALT_INSTRUCTION),    
       .RAM_WIDTH_DATOS            (RAM_WIDTH_DATOS),
       .RAM_WIDTH_PROGRAMA         (RAM_WIDTH_PROGRAMA),
       .RAM_PERFORMANCE_DATOS      (RAM_PERFORMANCE_DATOS),
       .RAM_PERFORMANCE_PROGRAMA   (RAM_PERFORMANCE_PROGRAMA),
       .INIT_FILE_DATOS            (INIT_FILE_DATOS),
       .INIT_FILE_PROGRAMA         (INIT_FILE_PROGRAMA),  
       .RAM_DEPTH_DATOS            (RAM_DEPTH_DATOS),
       .RAM_DEPTH_PROGRAMA         (RAM_DEPTH_PROGRAMA),
       .CANT_ESTADOS_DEBUG_UNIT    (CANT_ESTADOS_DEBUG_UNIT),
       .ADDR_MEM_PROGRAMA_LENGTH   (ADDR_MEM_PROGRAMA_LENGTH),
       .ADDR_MEM_DATOS_LENGTH      (ADDR_MEM_DATOS_LENGTH),
       .LONG_INSTRUCCION           (LONG_INSTRUCCION),
       .CANT_BITS_CONTROL_DATABASE_TOP (CANT_BITS_CONTROL_DATABASE_TOP),
       .CANT_SWITCHES               (CANT_SWITCHES),
       .CANT_BITS_SELECT_BYTES_MEM_DATA_TOP  (CANT_BITS_SELECT_BYTES_TOP) 
    ) 
   u_top_arquitectura_1
   (
     .i_clock_top (clock),
     .i_reset (hard_reset),
     .i_switches (reg_switches),
     .uart_txd_in (uart_txd_in_reg),
     .uart_rxd_out (uart_rxd_out_wire),
     .o_leds (wire_leds),
     .led0 (wire_led_rgb)
   );
  
endmodule